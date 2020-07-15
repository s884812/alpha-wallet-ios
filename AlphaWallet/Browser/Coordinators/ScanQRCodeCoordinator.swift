// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import QRCodeReaderViewController
import BigInt

protocol ScanQRCodeCoordinatorDelegate: class {
    func didCancel(in coordinator: ScanQRCodeCoordinator)
    func didScan(result: String, in coordinator: ScanQRCodeCoordinator)
}

protocol ScanQRCodeCoordinatorResolutionDelegate: class {
    func coordinator(_ coordinator: ScanQRCodeCoordinator, didResolveAddress address: AlphaWallet.Address, action: ScanQRCodeAction)
    func coordinator(_ coordinator: ScanQRCodeCoordinator, didResolveTransferType transferType: TransferType, token: TokenObject)
    func coordinator(_ coordinator: ScanQRCodeCoordinator, didResolveWalletConnectURL url: WCURL)
    func coordinator(_ coordinator: ScanQRCodeCoordinator, didResolveString value: String)
    func coordinator(_ coordinator: ScanQRCodeCoordinator, didResolveURL url: URL)
}

enum ScanQRCodeAction: CaseIterable {
    case sendToAddress
    case addCustomToken
    case watchWallet
    case openInEtherscan

    var title: String {
        switch self {
        case .sendToAddress:
            return R.string.localizable.qrCodeSendToAddressTitle()
        case .addCustomToken:
            return R.string.localizable.qrCodeAddCustomTokenTitle()
        case .watchWallet:
            return R.string.localizable.qrCodeWatchWalletTitle()
        case .openInEtherscan:
            return "Open in Etherscan"
        }
    }
}

typealias WCURL = String
private enum ScanQRCodeResolution {
    case value(value: QRCodeValue)
    case walletConnect(WCURL)
    case other(String)
    case url(URL)

    init(rawValue: String) {
        if let value = QRCodeValueParser.from(string: rawValue.trimmed) {
            self = .value(value: value)
        } else if rawValue.hasPrefix("wc:") {
            self = .walletConnect(rawValue)
        } else if let url = URL(string: rawValue) {
            self = .url(url)
        } else {
            self = .other(rawValue)
        }
    }
}

enum ScanQRCodeCoordinatorConfiguration {
    case empty
    case resolution(tokensDatastores: [TokensDataStore], assetDefinitionStore: AssetDefinitionStore)

    var shouldDissmissAfterScan: Bool {
        switch self {
        case .empty:
            return true
        case .resolution:
            return false
        }
    }
}

final class ScanQRCodeCoordinator: NSObject, Coordinator {
    private lazy var navigationController = UINavigationController(rootViewController: qrcodeController)
    private let parentNavigationController: UINavigationController
    private let shouldDissmissAfterScan: Bool
    //NOTE: We use flag to prevent camera view stuck when stop scan session, important for actions that can be canceled scan URL/WalletAddress
    private var skipResolvedCodes: Bool = false
    private lazy var reader = QRCodeReader(metadataObjectTypes: [AVMetadataObject.ObjectType.qr])
    private lazy var qrcodeController: QRCodeReaderViewController = {
        let controller = QRCodeReaderViewController(
            cancelButtonTitle: nil,
            codeReader: reader,
            startScanningAtLoad: true,
            showSwitchCameraButton: false,
            showTorchButton: true,
            chooseFromPhotoLibraryButtonTitle: R.string.localizable.photos(),
            bordersColor: Colors.qrCodeRectBorders,
            messageText: R.string.localizable.qrCodeTitle(),
            torchTitle: R.string.localizable.light(),
            torchImage: R.image.light(),
            chooseFromPhotoLibraryButtonImage: R.image.browse()
        )
        controller.delegate = self
        controller.title = R.string.localizable.browserScanQRCodeTitle()
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem.cancelBarButton(self, selector: #selector(dismiss))
        controller.delegate = self

        return controller
    }()
    private let configuration: ScanQRCodeCoordinatorConfiguration
    //NOTE: I am not sure that this is proper way to determine server, or its server that we need
    private var rpcServer: RPCServer {
        return RPCServer(chainID: Config.getChainId())
    }
    var coordinators: [Coordinator] = []
    weak var delegate: ScanQRCodeCoordinatorDelegate?
    weak var resolutionDelegate: ScanQRCodeCoordinatorResolutionDelegate?

    init(navigationController: UINavigationController, configuration: ScanQRCodeCoordinatorConfiguration = .empty) {
        self.parentNavigationController = navigationController
        self.shouldDissmissAfterScan = configuration.shouldDissmissAfterScan
        self.configuration = configuration
    }

    func start() {
        navigationController.makePresentationFullScreenForiOS13Migration()
        parentNavigationController.present(navigationController, animated: true)
    }

    @objc func dismiss() {
        stopScannerAndDissmiss {
            self.delegate?.didCancel(in: self)
        }
    }

    func resolveScanResult(_ rawValue: String) {
        guard let delegate = resolutionDelegate else { return }

        switch ScanQRCodeResolution(rawValue: rawValue) {
        case .value(let value):
            switch value {
            case .address(let contract):
                switch configuration {
                case .resolution(let tokensDatastores, _):
                    let actions: [ScanQRCodeAction]
                    //NOTE: or meybe we need pass though all servers?
                    guard let tokensDatastore = tokensDatastores.first(where: { $0.server == rpcServer }) else { return }

                    //I guess if we have token, we shouldn't be able to send to it, or we should?
                    if tokensDatastore.token(forContract: contract) != nil {
                        actions = [.openInEtherscan]
                    } else {
                        actions = [.sendToAddress, .addCustomToken, .watchWallet, .openInEtherscan]
                    }

                    showDidScanWalletAddress(for: actions, completion: { action in
                        self.stopScannerAndDissmiss {
                            delegate.coordinator(self, didResolveAddress: contract, action: action)
                        }
                    }, cancelCompletion: {
                        self.skipResolvedCodes = false
                    })
                case .empty:
                    break
                }

            case .eip681(let protocolName, let address, let function, let params):
                stopScannerAndDissmiss {
                    self.checkAndFillEIP681Details(protocolName: protocolName, address: address, functionName: function, params: params)
                }
            }
        case .other(let value):
            stopScannerAndDissmiss {
                delegate.coordinator(self, didResolveString: value)
            }
        case .walletConnect(let url):
            stopScannerAndDissmiss {
                delegate.coordinator(self, didResolveWalletConnectURL: url)
            }
        case .url(let url):
            showOpenURL(completion: {
                self.stopScannerAndDissmiss {
                    delegate.coordinator(self, didResolveURL: url)
                }
            }, cancelCompletion: {
                //NOTE: we need to reset flat to false to make shure that next detected QR code will be handled
                self.skipResolvedCodes = false
            })
        }
    }

    private func checkAndFillEIP681Details(protocolName: String, address: AddressOrEnsName, functionName: String?, params: [String: String]) {
        switch configuration {
        case .resolution(let tokensDatastores, let assetDefinitionStore):
            Eip681Parser(protocolName: protocolName, address: address, functionName: functionName, params: params).parse().done { [weak self] result in
                guard let strongSelf = self, let resolutionDelegate = strongSelf.resolutionDelegate else { return }

                guard let (contract: contract, customServer, recipient, maybeScientificAmountString) = result.parameters else {
                    return
                }

                guard let storage = tokensDatastores.first(where: { $0.server == customServer ?? strongSelf.rpcServer }) else { return }

                if let token = storage.token(forContract: contract) {
                    
                    let transferType = TransferType(token: token, recipient: recipient, amount: maybeScientificAmountString)
                    resolutionDelegate.coordinator(strongSelf, didResolveTransferType: transferType, token: token)
                } else {
                    fetchContractDataFor(address: contract, storage: storage, assetDefinitionStore: assetDefinitionStore) { result in
                        switch result {
                        case .name, .symbol, .balance, .decimals, .nonFungibleTokenComplete, .delegateTokenComplete, .failed:
                            break //no op
                        case .fungibleTokenComplete(let name, let symbol, let decimals):
                            let token = storage.addCustom(token: .init(
                                contract: contract,
                                server: storage.server,
                                name: name,
                                symbol: symbol,
                                decimals: Int(decimals),
                                type: .erc20,
                                balance: ["0"]
                            ))

                            let transferType = TransferType(token: token, recipient: recipient, amount: maybeScientificAmountString)
                            resolutionDelegate.coordinator(strongSelf, didResolveTransferType: transferType, token: token)
                        }
                    }
                }
            }.cauterize()
        default:
            break
        }
    }

    private func showDidScanWalletAddress(for actions: [ScanQRCodeAction], completion: @escaping (ScanQRCodeAction) -> Void, cancelCompletion: @escaping () -> Void) {
        let preferredStyle: UIAlertController.Style = UIDevice.current.userInterfaceIdiom == .pad ? .alert : .actionSheet
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: preferredStyle)

        for action in actions {
            let alertAction = UIAlertAction(title: action.title, style: .default) { _ in
                completion(action)
            }

            controller.addAction(alertAction)
        }

        let cancelAction = UIAlertAction(title: R.string.localizable.cancel(), style: .cancel) { _ in
            cancelCompletion()
        }

        controller.addAction(cancelAction)

        controller.makePresentationFullScreenForiOS13Migration()

        navigationController.present(controller, animated: true)
    }

    private func showOpenURL(completion: @escaping () -> Void, cancelCompletion: @escaping () -> Void) {
        let preferredStyle: UIAlertController.Style = UIDevice.current.userInterfaceIdiom == .pad ? .alert : .actionSheet
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: preferredStyle)

        let alertAction = UIAlertAction(title: R.string.localizable.qrCodeOpenInBrowserTitle(), style: .default) { _ in
            completion()
        }

        let cancelAction = UIAlertAction(title: R.string.localizable.cancel(), style: .cancel) { _ in
            cancelCompletion()
        }

        controller.addAction(alertAction)
        controller.addAction(cancelAction)

        controller.makePresentationFullScreenForiOS13Migration()

        navigationController.present(controller, animated: true)
    }

    private func stopScannerAndDissmiss(completion: @escaping () -> Void) {
        reader.stopScanning()

        navigationController.dismiss(animated: true, completion: completion)
    }
}

extension ScanQRCodeCoordinator: QRCodeReaderDelegate {

    func readerDidCancel(_ reader: QRCodeReaderViewController!) {
        stopScannerAndDissmiss {
            self.delegate?.didCancel(in: self)
        }
    }

    func reader(_ reader: QRCodeReaderViewController!, didScanResult result: String!) {
        guard !skipResolvedCodes else { return }

        if shouldDissmissAfterScan {
            stopScannerAndDissmiss {
                self.delegate?.didScan(result: result, in: self)
            }
        } else {
            skipResolvedCodes = true
            delegate?.didScan(result: result, in: self)
        }
    }
}

extension UIBarButtonItem {
    
    static func cancelBarButton(_ target: AnyObject, selector: Selector) -> UIBarButtonItem {
        return .init(barButtonSystemItem: .cancel, target: target, action: selector)
    }

    static func closeBarButton(_ target: AnyObject, selector: Selector) -> UIBarButtonItem {
        return .init(image: R.image.close(), style: .plain, target: target, action: selector)
    }
}

extension String {
    var scientificAmountToBigInt: BigInt? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.usesGroupingSeparator = false

        let amountString = numberFormatter.number(from: self).flatMap { numberFormatter.string(from: $0) }
        return amountString.flatMap { BigInt($0) }
    }
}
