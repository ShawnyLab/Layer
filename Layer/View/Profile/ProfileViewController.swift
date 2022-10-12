//
//  ProfileViewController.swift
//  Layer
//
//  Created by 박진서 on 2022/07/27.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

final class ProfileViewController: UIViewController {
    static let storyId = "profileVC"

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var desLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImageView.layer.cornerRadius = 39.5
        
        profileImageView.setImage(url: CurrentUserModel.shared.profileImageUrl)
        nameLabel.text = CurrentUserModel.shared.name
        desLabel.text = CurrentUserModel.shared.des
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80

        
        Observable.just(CurrentUserModel.shared.frameModels)
            .bind(to: tableView.rx.items(cellIdentifier: MyFrameCell.reuseId, cellType: MyFrameCell.self)) { idx, simpleFrameModel, cell in
                if idx == CurrentUserModel.shared.frameModels.count-1 {
                    cell.barView.isHidden = true
                } else {
                    cell.barView.isHidden = false
                }
                
                cell.titleLabel.text = simpleFrameModel.title
                if let imgUrl = simpleFrameModel.imageUrl {
                    cell.contentImageView.setImage(url: imgUrl)
                } else {
                    cell.contentImageView.isHidden = true
                }
                
                cell.greydot.layer.cornerRadius = 4
            }
            .disposed(by: rx.disposeBag)
        
        
    }
    

}




final class MyFrameCell: UITableViewCell {
    static let reuseId = "myframeCell"
    
    @IBOutlet weak var greydot: UIView!
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var barView: UIView!
    
}
