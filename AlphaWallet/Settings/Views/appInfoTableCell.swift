//
//  appInfoTableCell.swift
//  AlphaWallet
//
//  Created by Nimit Parekh on 07/04/20.
//

import UIKit

//hhh rename file if keep
//hhh rename if keep
//hhh clean or keep at all?
//hhh if keep: comments, constraints, etc
class AppInfoTableCell: UITableViewCell {
    //hhh private most?
    let containerView: UIView = {
           let view = UIView()
           view.translatesAutoresizingMaskIntoConstraints = false
           view.clipsToBounds = true
           view.backgroundColor = UIColor.clear
           return view
       }()

    var settings: SettingFooterModel? {
        didSet {
            guard let settingItem = settings else { return }
            if let title = settingItem.title {
                settingTitle.text = title
            }
            if let subtitle = settingItem.subTitle {
                settingSubTitle.text = subtitle
            }
            backgroundColor = R.color.alabaster()
        }
    }

    let settingTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = R.color.dove()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let settingSubTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.textColor =  R.color.dove()
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        containerView.addSubview(settingTitle)
        containerView.addSubview(settingSubTitle)
        contentView.addSubview(containerView)

        containerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -22).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 40).isActive = true

        settingTitle.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        settingTitle.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true

        settingSubTitle.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        settingSubTitle.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
