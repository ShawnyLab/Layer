//
//  FrameTableViewCell.swift
//  Layer
//
//  Created by 박진서 on 2022/07/30.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

final class FrameTableViewCell: UITableViewCell {

    static let reuseId = "frameCell"

    //MARK: Writer
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var optionBtn: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var dueLabel: UILabel!
        
    func bind(frameModel: FrameModel) {
        profileImageView.layer.cornerRadius = 12.5
        
        if let imageUrl = frameModel.imageUrl {
            contentImageView.isHidden = false
            contentImageView.setImage(url: imageUrl)
        } else {
            contentImageView.isHidden = true
        }
        
        titleLabel.text = frameModel.title
        contentLabel.text = frameModel.content


        
        if frameModel.dueDate == nil {
            dueLabel.isHidden = true
        } else {
            dueLabel.isHidden = false
        }

    }
}
