// Copyright © 2018 Stormbird PTE. LTD.

import UIKit
//hhh remove
import Eureka
//hhh needed?
import StoreKit
//hhh needed?
import MessageUI

//hhh clean up
//protocol SettingsViewControllerDelegate: class, CanOpenURL {
//    func didAction(action: AlphaWalletSettingsAction, in viewController: SettingsViewController)
//    func assetDefinitionsOverrideViewController(for: SettingsViewController) -> UIViewController?
//    func consoleViewController(for: SettingsViewController) -> UIViewController?
//}

//hhh rename to remove "3"
//hhh keep but remove most
class SettingsViewController3: FormViewController {
    private let iconInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
    private let cellWithSubtitleHeight = CGFloat(66)
    private let lock = Lock()
    private var isPasscodeEnabled: Bool {
        return lock.isPasscodeSet
    }
    private lazy var viewModel: SettingsViewModel = {
        return SettingsViewModel(isDebug: isDebug)
    }()
    private let keystore: Keystore
    private let account: Wallet
    private let promptBackupWalletViewHolder = UIView()
    //hhh rename
    //hhh which style?
    private let settingTableView = UITableView(frame: .zero, style: .plain)

    //hhh remove?
    lazy private var foo: Foo = Foo(vc: self)

    weak var delegate: SettingsViewControllerDelegate?
    var promptBackupWalletView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let promptBackupWalletView = promptBackupWalletView {
                promptBackupWalletView.translatesAutoresizingMaskIntoConstraints = false
                promptBackupWalletViewHolder.addSubview(promptBackupWalletView)
                NSLayoutConstraint.activate([
                    promptBackupWalletView.leadingAnchor.constraint(equalTo: promptBackupWalletViewHolder.leadingAnchor, constant: 7),
                    promptBackupWalletView.trailingAnchor.constraint(equalTo: promptBackupWalletViewHolder.trailingAnchor, constant: -7),
                    promptBackupWalletView.topAnchor.constraint(equalTo: promptBackupWalletViewHolder.topAnchor, constant: 7),
                    promptBackupWalletView.bottomAnchor.constraint(equalTo: promptBackupWalletViewHolder.bottomAnchor, constant: 0),
                ])
                tabBarItem.badgeValue = "1"
                showPromptBackupWalletViewAsTableHeaderView()
            } else {
                hidePromptBackupWalletView()
                tabBarItem.badgeValue = nil
            }
        }
    }

    init(keystore: Keystore, account: Wallet) {
        self.keystore = keystore
        self.account = account
        super.init(style: .plain)
        title = R.string.localizable.aSettingsNavigationTitle()

        //hhh clean up

        //hhh remove?
        //settingTableView.showsVerticalScrollIndicator = false
        //hhh constant
        //hhh fix cell classes
        settingTableView.register(SettingViewHeader.self, forHeaderFooterViewReuseIdentifier: "SettingHeaderView")
        settingTableView.register(SettingTableViewCell.self, forCellReuseIdentifier: "settingCell")
        //hhh different cell
        //settingTableView.register(AppInfoTableCell.self, forCellReuseIdentifier: "appInfoCell")
        //settingTableView.register(AppInfoTableCell.self, forCellReuseIdentifier: "settingCell")

        //hhh switch data source?
        settingTableView.dataSource = foo
        settingTableView.delegate = foo

        settingTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(settingTableView)

        NSLayoutConstraint.activate([
            //hhh replace with that 1 liner wrapper func
            //hhh safe? No?
            settingTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            settingTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            //hhh remove constant
            //settingTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 150),
            //settingTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 150),
            settingTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            settingTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }

// swiftlint:disable function_body_length
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Screen.Setting.Color.background
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = GroupedTable.Color.background
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.contentInset.bottom = 60
        view.addSubview(tableView)

        let section = Section()

        <<< AlphaWalletSettingsButtonRow { button in
            button.cellStyle = .subtitle
        }.onCellSelection { [unowned self] _, _ in
            //hhh restore
            //self.delegate?.didAction(action: .myWalletAddress, in: self)
        }.cellUpdate { [weak self] cell, _ in
            guard let strongSelf = self else { return }
            cell.height = { strongSelf.cellWithSubtitleHeight }
            cell.imageView?.image = R.image.settings_wallet1()?.imageWithInsets(insets: strongSelf.iconInset)?.withRenderingMode(.alwaysTemplate)
            cell.textLabel?.text = R.string.localizable.aSettingsContentsMyWalletAddress()
            cell.detailTextLabel?.text = strongSelf.account.address.eip55String
            cell.detailTextLabel?.lineBreakMode = .byTruncatingMiddle
            cell.accessoryType = .disclosureIndicator
        }

        <<< AlphaWalletSettingsButtonRow { button in
            button.cellStyle = .value1
        }.onCellSelection { [unowned self] _, _ in
            self.run(action: .wallets)
        }.cellUpdate { [weak self] cell, _ in
            guard let strongSelf = self else { return }
            cell.imageView?.image = R.image.settings_wallet()?.imageWithInsets(insets: strongSelf.iconInset)?.withRenderingMode(.alwaysTemplate)
            cell.textLabel?.text = R.string.localizable.settingsWalletsButtonTitle()
            cell.accessoryType = .disclosureIndicator
        }

        switch account.type {
        case .real:
            section
            <<< AlphaWalletSettingsButtonRow {
                $0.title = R.string.localizable.settingsBackupWalletButtonTitle()
            }.onCellSelection { [unowned self] _, _ in
                //hhh restore
                //self.delegate?.didAction(action: .backupWallet, in: self)
            }.cellUpdate { [weak self] cell, _ in
                guard let strongSelf = self else { return }
                cell.imageView?.image = R.image.settings_wallet_backup()?.imageWithInsets(insets: strongSelf.iconInset)?.withRenderingMode(.alwaysTemplate)
                let walletSecurityLevel = PromptBackupCoordinator(keystore: strongSelf.keystore, wallet: strongSelf.account, config: .init()).securityLevel
                cell.accessoryView = walletSecurityLevel.flatMap { WalletSecurityLevelIndicator(level: $0) }
                cell.textLabel?.textAlignment = .left
            }
        case .watch:
            break
        }

        section

        <<< AlphaWalletSettingsButtonRow { button in
            button.cellStyle = .subtitle
        }.onCellSelection { [unowned self] _, _ in
            self.run(action: .locales)
        }.cellUpdate { [weak self] cell, _ in
            guard let strongSelf = self else { return }
            cell.height = { strongSelf.cellWithSubtitleHeight }
            cell.imageView?.image = R.image.settings_language()?.imageWithInsets(insets: strongSelf.iconInset)?.withRenderingMode(.alwaysTemplate)
            cell.textLabel?.text = strongSelf.viewModel.localeTitle
            cell.detailTextLabel?.text = AppLocale(id: Config.getLocale()).displayName
            cell.accessoryType = .disclosureIndicator
        }

        <<< AlphaWalletSettingsSwitchRow { [weak self] in
            $0.title = self?.viewModel.passcodeTitle
            $0.value = self?.isPasscodeEnabled
        }.onChange { [unowned self] row in
            if row.value == true {
                self.setPasscode { result in
                    row.value = result
                    row.updateCell()
                }
            } else {
                self.lock.deletePasscode()
            }
        }.cellUpdate { cell, _ in
            cell.textLabel?.textColor = Screen.Setting.Color.title
            cell.imageView?.tintColor = Screen.Setting.Color.image
            cell.imageView?.image = R.image.settings_lock()?.imageWithInsets(insets: self.iconInset)?.withRenderingMode(.alwaysTemplate)
        }

        <<< AlphaWalletSettingsButtonRow { button in
            button.cellStyle = .value1
        }.onCellSelection { [unowned self] _, _ in
            self.run(action: .enabledServers)
        }.cellUpdate { cell, _ in
            cell.imageView?.image = R.image.settings_server()?.imageWithInsets(insets: self.iconInset)?.withRenderingMode(.alwaysTemplate)
            cell.textLabel?.text = R.string.localizable.settingsEnabledNetworksButtonTitle()
            cell.accessoryType = .disclosureIndicator
        }
        <<< AlphaWalletSettingsButtonRow { row in
            row.cellStyle = .value1
            //hhh restore
            //row.presentationMode = .show(controllerProvider: ControllerProvider<UIViewController>.callback {
            //    let vc = self.delegate?.assetDefinitionsOverrideViewController(for: self) ?? UIViewController()
            //    vc.navigationItem.largeTitleDisplayMode = .never
            //    return vc
            //}, onDismiss: { _ in
            //})
        }.cellUpdate { cell, _ in
            cell.textLabel?.text = R.string.localizable.aHelpAssetDefinitionOverridesTitle()
            cell.imageView?.image = R.image.settings_tokenscript_overrides()?.imageWithInsets(insets: self.iconInset)?.withRenderingMode(.alwaysTemplate)
            cell.accessoryType = .disclosureIndicator
        }
        <<< AlphaWalletSettingsButtonRow { row in
            row.cellStyle = .value1
            //hhh restore
            //row.presentationMode = .show(controllerProvider: ControllerProvider<UIViewController>.callback {
            //    let vc = self.delegate?.consoleViewController(for: self) ?? UIViewController()
            //    vc.navigationItem.largeTitleDisplayMode = .never
            //    return vc
            //}, onDismiss: { _ in
            //})
        }.cellUpdate { cell, _ in
            cell.imageView?.image = R.image.settings_console()?.imageWithInsets(insets: self.iconInset)?.withRenderingMode(.alwaysTemplate)
            cell.textLabel?.text = R.string.localizable.aConsoleTitle()
            cell.accessoryType = .disclosureIndicator
        }
        <<< AlphaWalletSettingsButtonRow { row in
            row.cellStyle = .value1
        }.onCellSelection { [unowned self] _, _ in
            //hhh restore
            //self.delegate?.didAction(action: .clearDappBrowserCache, in: self)
        }.cellUpdate { cell, _ in
            cell.textLabel?.text = R.string.localizable.aSettingsContentsClearDappBrowserCache()
            cell.imageView?.image = R.image.settings_clear_dapp_cache()?.imageWithInsets(insets: self.iconInset)?.withRenderingMode(.alwaysTemplate)
        }

        <<< linkProvider(type: .telegram)
        <<< linkProvider(type: .twitter)
        <<< linkProvider(type: .reddit)
        <<< linkProvider(type: .facebook)
        <<< AlphaWalletSettingsButtonRow { row in
            row.cellStyle = .value1
            row.presentationMode = .show(controllerProvider: ControllerProvider<UIViewController>.callback {
                let vc = HelpViewController(delegate: self)
                vc.navigationItem.largeTitleDisplayMode = .never
                vc.hidesBottomBarWhenPushed = true
                return vc
            }, onDismiss: { _ in
            })
        }.cellUpdate { cell, _ in
            cell.imageView?.image = R.image.settings_faq()?.imageWithInsets(insets: self.iconInset)?.withRenderingMode(.alwaysTemplate)
            cell.textLabel?.text = R.string.localizable.aHelpNavigationTitle()
            cell.accessoryType = .disclosureIndicator
        }

        <<< AlphaWalletSettingsTextRow {
            $0.disabled = true
        }.cellSetup { cell, _ in
            cell.mainLabel.text = R.string.localizable.settingsVersionLabelTitle()
            cell.subLabel.text = "\(Bundle.main.fullVersion)"
        }
        <<< AlphaWalletSettingsTextRow {
            $0.disabled = true
        }.cellSetup { cell, _ in
            cell.mainLabel.text = R.string.localizable.settingsTokenScriptStandardTitle()
            cell.subLabel.text = "\(TokenScript.supportedTokenScriptNamespaceVersion)"
        }.onCellSelection { [unowned self] _, _ in
            self.delegate?.didPressOpenWebPage(TokenScript.tokenScriptSite, in: self)
        }

        form +++ section

        //Check for nil is important because the prompt might have been shown before viewDidLoad
        if promptBackupWalletView == nil {
            hidePromptBackupWalletView()
        }

        NSLayoutConstraint.activate([
            tableView.anchorsConstraint(to: view),
        ])
    }
// swiftlint:enable function_body_length

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reflectCurrentWalletSecurityLevel()
    }

    private func showPromptBackupWalletViewAsTableHeaderView() {
        let size = promptBackupWalletViewHolder.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        promptBackupWalletViewHolder.bounds.size.height = size.height
        //Access `view` to force it to be created to avoid crashing when we access `tableView` next, because `tableView` is only created after that, and is defined as `UITableView!`.
        let _ = view
        tableView.tableHeaderView = promptBackupWalletViewHolder
    }

    private func hidePromptBackupWalletView() {
        //`tableView` is defined as `UIUTableView!` and may not have been created yet
        guard tableView != nil && tableView.tableHeaderView != nil else { return }
        tableView.tableHeaderView = nil
    }

    private func reflectCurrentWalletSecurityLevel() {
        tableView.reloadData()
    }

    func setPasscode(completion: ((Bool) -> Void)? = .none) {
        let lock = LockCreatePasscodeCoordinator(navigationController: navigationController!, model: LockCreatePasscodeViewModel())
        lock.start()
        lock.lockViewController.willFinishWithResult = { result in
            completion?(result)
            lock.stop()
        }
    }

    private func linkProvider(
            type: URLServiceProvider
    ) -> AlphaWalletSettingsButtonRow {
        return AlphaWalletSettingsButtonRow {
            $0.title = type.title
        }.onCellSelection { [unowned self] _, _ in
            if let localURL = type.localURL, UIApplication.shared.canOpenURL(localURL) {
                UIApplication.shared.open(localURL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: .none)
            } else {
                self.delegate?.didPressOpenWebPage(type.remoteURL, in: self)
            }
        }.cellUpdate { cell, _ in
            cell.textLabel?.textAlignment = .left
            cell.imageView?.image = type.image?.imageWithInsets(insets: self.iconInset)?.withRenderingMode(.alwaysTemplate)
        }
    }

    func run(action: AlphaWalletSettingsAction) {
        //hhh restore
        //delegate?.didAction(action: action, in: self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SettingsViewController3: HelpViewControllerDelegate {
}

extension SettingsViewController3: CanOpenURL {
    func didPressViewContractWebPage(forContract contract: AlphaWallet.Address, server: RPCServer, in viewController: UIViewController) {
        delegate?.didPressViewContractWebPage(forContract: contract, server: server, in: viewController)
    }

    func didPressViewContractWebPage(_ url: URL, in viewController: UIViewController) {
        delegate?.didPressViewContractWebPage(url, in: viewController)
    }

    func didPressOpenWebPage(_ url: URL, in viewController: UIViewController) {
        delegate?.didPressOpenWebPage(url, in: viewController)
    }
}

// Helper function inserted by Swift 4.2 migrator.
private func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value) })
}

extension UIImage {
    fileprivate func imageWithInsets(insets: UIEdgeInsets) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions( CGSize(width: size.width + insets.left + insets.right, height: size.height + insets.top + insets.bottom), false, scale)
        let _ = UIGraphicsGetCurrentContext()
        let origin = CGPoint(x: insets.left, y: insets.top)
        draw(at: origin)
        let imageWithInsets = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return imageWithInsets
    }
}

//hhh remove
class Foo: NSObject {
    private let vc: SettingsViewController3

    //hhh clean up
    private let sections = [
        //hhh localize
        (title: "Wallet", rows: [
            SettingModel(title: "Show My Wallet Address", subTitle: "", icon: R.image.walletAddress()),
            SettingModel(title: "Change / Add Wallet", subTitle: "tomek.eth | 0x4524...6363", icon: R.image.changeWallet()),
            SettingModel(title: R.string.localizable.settingsBackupWalletButtonTitle(), subTitle: "", icon: R.image.backupCircle()),
        ]),
        (title: "Settings", rows: [
            SettingModel(title: "Notifications", subTitle: "", icon: R.image.notificationsCircle()),
            SettingModel(title: "Passcode / Touch ID", subTitle: "", icon: R.image.biometrics()),
            SettingModel(title: "Select Active Networks", subTitle: "", icon: R.image.networksCircle()),
            SettingModel(title: R.string.localizable.advanced(), subTitle: "", icon: R.image.developerMode()),
        ]),
        (title: "Help", rows: [
            SettingModel(title: "Support", subTitle: "", icon: R.image.support())
        ]),
        (title: "Footer", rows: [
            //hhhh should show sideways
            SettingModel(title: "App Version", subTitle: "2.20.0(23)", icon: nil),
            SettingModel(title: "TokenScript Standard", subTitle: "2019/10", icon: nil)
        ]),
    ]

    //hhh all references to vc might turn into self. And make the property/func private
    init(vc: SettingsViewController3) {
        self.vc = vc
    }
}

//hhh move most back into SettingsViewController3
extension Foo: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section < sections.count else { return 0 }
        let section = sections[section]
        return section.rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        //hhh footer shouldn't be here
        //hhh magic
        if indexPath.section == 3 {
            //hhh different cell
            //let cells = tableView.dequeueReusableCell(withIdentifier: "appInfoCell", for: indexPath) as? AppInfoTableCell
            let cells = tableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath) as? SettingTableViewCell
            cells!.selectionStyle = .none
            cells!.settings = section.rows[indexPath.row]
            return cells!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath) as! SettingTableViewCell
            cell.selectionStyle = .none
            cell.accessoryType = .disclosureIndicator
            //hhh restore?
            //cell.delegate = self
            //hhh magic
            if indexPath.row == 1 && indexPath.section == 1 {
                cell.tableSwitch.isHidden = false
                cell.accessoryType = .none
            }
            cell.settings = section.rows[indexPath.row]
            return cell
        }
    }
}

//hhh move most back into SettingsViewController3
extension Foo: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //hhh auto layout?
        //hhh fix magic
        if indexPath.row == 1 && indexPath.section == 0 {
            return 80
            //hhh fix magic
        } else if indexPath.section == 3 {
            return  50
        }
        return 60
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //hhh magic and rewrite
        if section == 3 {
            return 0
        }
        return 50
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //hhh correct?
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SettingHeaderView") as! SettingViewHeader
        let section = sections[section]
        headerView.title = section.title ?? ""
        return headerView
    }
}
