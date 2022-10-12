//
//  SentRequestViewController.swift
//  Layer
//
//  Created by 박진서 on 2022/10/12.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class SentRequestViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Observable.just(CurrentUserModel.shared.friends.filter { $0.layer == -1 })
            .bind(to: tableView.rx.items(cellIdentifier: "sentrequestCell", cellType: SentRequestCell.self)) { [unowned self] idx, friendModel, cell in

                UserManager.shared.fetch(id: friendModel.uid)
                    .subscribe(onSuccess: { [unowned self] userModel in
                        cell.layerIdLabel.text = userModel.layerId
                        cell.nameLabel.text = userModel.name
                        cell.profileImageView.setImage(url: userModel.profileImageUrl)
                    })
                    .disposed(by: rx.disposeBag)
                
            }
            .disposed(by: rx.disposeBag)
            
            
    }
    



}

final class SentRequestCell: UITableViewCell {
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var layerIdLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    override func awakeFromNib() {
        cancelButton.layer.cornerRadius = 13
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.black.cgColor
        
        profileImageView.layer.cornerRadius = 20
    }
}
