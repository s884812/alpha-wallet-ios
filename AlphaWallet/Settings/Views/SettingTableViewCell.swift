//
//  SettingTableViewCell.swift
//  AlphaWallet
//
//  Created by Nimit Parekh on 06/04/20.
//

import UIKit

protocol SettingTableViewCellDelegate: class {
    //hhh anything to fix?
    //hhh no good. Generalise name?
    func onOffPassCode(cell: SettingTableViewCell, switchState isOnOff: Bool)
}

//hhh rename?
//hhh keep?
class SettingTableViewCell: UITableViewCell {
    //hhh private most?
    weak var delegate: SettingTableViewCellDelegate?

    //hhh configure instead
    //hhhh rename
    var settings: SettingModel? {
        didSet {
            guard let settingItem = settings else { return }
            if let title = settingItem.title {
                settingTitle.text = title
            }
            if let subtitle = settingItem.subTitle {
                settingSubTitle.text = subtitle
                settingSubTitle.isHidden = subtitle.isEmpty
            }
            if let icon = settingItem.icon {
                settingIconImage.image = icon
            }
        }
    }
    //hhh private most
    let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()

    let settingIconImage: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill
        img.translatesAutoresizingMaskIntoConstraints = false
        img.clipsToBounds = true
        return img
    }()

    let settingTitle: UILabel = {
        let label = UILabel()
        label.font = R.font.sourceSansProRegular(size: 17)
        label.textColor = R.color.black()
        return label
    }()

    let settingSubTitle: UILabel = {
        let label = UILabel()
        label.font = R.font.sourceSansProRegular(size: 12)
        label.textColor =  R.color.dove()
        label.clipsToBounds = true
        return label
    }()

    //hhh rename most properties
    let tableSwitch: UISwitch = {
        let switchBtn = UISwitch()
        switchBtn.isHidden = true
        switchBtn.translatesAutoresizingMaskIntoConstraints = false
        switchBtn.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        return switchBtn
    }()

    @objc func switchChanged(_ sender: Any) {
        //hhh remove most comments
        // switch was tapped (toggled on/off)
        //hhh no good?
        if let v = sender as? UISwitch {
            delegate?.onOffPassCode(cell: self, switchState: v.isOn)
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let titlesStackView = [
            settingTitle,
            //hhh rename. lowercase T
            settingSubTitle,
        ].asStackView(axis: .vertical)
        titlesStackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titlesStackView)

        containerView.addSubview(settingIconImage)
        containerView.addSubview(tableSwitch)
        //hhh remove commented out code
//    containerView.backgroundColor = UIColor.red
        contentView.addSubview(containerView)

        NSLayoutConstraint.activate([
            settingIconImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            settingIconImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            settingIconImage.widthAnchor.constraint(equalTo: settingIconImage.heightAnchor),
            settingIconImage.widthAnchor.constraint(equalToConstant: 40),

            titlesStackView.leadingAnchor.constraint(equalTo: settingIconImage.trailingAnchor, constant: 20),
            titlesStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            titlesStackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),

            //hhh should it be accessor instead? Actually can't this be in the accessory view? Or not?
            tableSwitch.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            //hhhhh not good. Should not overlap
            tableSwitch.leadingAnchor.constraint(equalTo: titlesStackView.trailingAnchor, constant: -68),

            containerView.anchorsConstraint(to: contentView),
            containerView.heightAnchor.constraint(equalToConstant: 60),
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
