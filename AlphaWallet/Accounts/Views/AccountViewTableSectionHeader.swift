// Copyright © 2019 Stormbird PTE. LTD.

import Foundation
import UIKit

class AccountViewTableSectionHeader: UIView {
    enum HeaderType: Int {
        case hdWallet = 0
        case keystoreWallet = 1
        case watchedWallet = 2

        var title: String {
            switch self {
            case .hdWallet:
                return R.string.localizable.walletTypesHdWallets().uppercased()
            case .keystoreWallet:
                return R.string.localizable.walletTypesKeystoreWallets().uppercased()
            case .watchedWallet:
                return R.string.localizable.walletTypesWatchedWallets().uppercased()
            }
        }
    }

    private let label = UILabel()
    private var heightConstraint: NSLayoutConstraint?
    private var constraintsWhenVisible: [NSLayoutConstraint] = []
    private let topSeperatorView = UIView.tableHeaderFooterViewSeparatorView()
    private let bottomSeperatorView = UIView.tableHeaderFooterViewSeparatorView()

    override init(frame: CGRect) {
        super.init(frame: CGRect())

        label.translatesAutoresizingMaskIntoConstraints = false

        addSubview(topSeperatorView)
        addSubview(bottomSeperatorView)
        addSubview(label)

        let topConstraint = label.topAnchor.constraint(equalTo: topSeperatorView.bottomAnchor, constant: 13)
        let bottomConstraint = label.bottomAnchor.constraint(equalTo: bottomSeperatorView.topAnchor, constant: -13)
        let constraintsWhenVisible = [
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),

            topSeperatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            topSeperatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            topSeperatorView.topAnchor.constraint(equalTo: topAnchor),

            bottomSeperatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomSeperatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomSeperatorView.bottomAnchor.constraint(equalTo: bottomAnchor),

            topConstraint,
            bottomConstraint
        ]

        NSLayoutConstraint.activate(constraintsWhenVisible)

        //UIKit doesn't like headers with a height of 0
        heightConstraint = heightAnchor.constraint(equalToConstant: 1)
        self.constraintsWhenVisible = constraintsWhenVisible
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(type: HeaderType, shouldHide: Bool) {
        backgroundColor  = GroupedTable.Color.background

        label.backgroundColor = GroupedTable.Color.background
        label.textColor = GroupedTable.Color.title
        label.font = Fonts.tableHeader
        label.text = type.title
        label.isHidden = shouldHide

        heightConstraint?.isActive = shouldHide
        if shouldHide {
            NSLayoutConstraint.deactivate(constraintsWhenVisible)
        } else {
            NSLayoutConstraint.activate(constraintsWhenVisible)
        }
    }
}

extension UIView {
    static func tableHeaderFooterViewSeparatorView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        view.backgroundColor = DataEntry.Color.border
        
        return view
    }
}
