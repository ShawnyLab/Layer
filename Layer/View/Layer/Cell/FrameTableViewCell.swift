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

class FrameTableViewCell: UITableViewCell {

    static let reuseId = "frameCell"

    //MARK: Writer
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var optionBtn: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    
    let userModel = BehaviorSubject<UserModel?>(value: nil)
    let imageUrl = BehaviorRelay<String?>(value: nil)
    
    func bind(frameModel: FrameModel) {
        profileImageView.layer.cornerRadius = 12.5
        
        if let imageUrl = frameModel.imageUrl {
            contentImageView.setImage(url: imageUrl)
        } else {
            contentImageView.isHidden = true
        }
        
        titleLabel.text = frameModel.title
        contentLabel.text = frameModel.content
        
        UserManager.shared.fetch(id: frameModel.writerId)
            .subscribe(onSuccess: { userModel in
                self.userModel.onNext(userModel)
            })
            .disposed(by: rx.disposeBag)
        
        userModel.subscribe(onNext: { [unowned self] userModel in
            if let userModel = userModel {
                nameLabel.text = userModel.name
                profileImageView.setImage(url: userModel.profileImageUrl)
            }
        })
        .disposed(by: rx.disposeBag)

    }
}
