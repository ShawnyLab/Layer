//
//  SearchUserViewController.swift
//  Layer
//
//  Created by 박진서 on 2022/12/01.
//

import UIKit
import RxSwift
import RxCocoa

final class SearchUserViewController: UIViewController {
    
    static let storyId = "searchuserVC"

    var topVC : UIViewController!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var textfield: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    private let userRelay = BehaviorRelay<[UserModel]>(value: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchButton.rx.tap
            .bind { [unowned self] _ in
                self.view.endEditing(true)
                if textfield.text?.count ?? 0 < 2 {
                    self.presentAlert(message: "2자 이상 입력해주세요.")
                } else {
                    UserManager.shared.search(id: textfield.text!)
                        .subscribe { [unowned self] userModel in
                            userRelay.accept(userModel)
                        }
                        .disposed(by: rx.disposeBag)
                }
            }
            .disposed(by: rx.disposeBag)
        
        userRelay
            .bind(to: tableView.rx.items(cellIdentifier: SearchUserCell.reuseId, cellType: SearchUserCell.self)) { idx, userModel, cell in
                cell.profileImageView.setImage(url: userModel.profileImageUrl)
                cell.idLabel.text = userModel.layerId
                cell.selectionStyle = .none
            }
            .disposed(by: rx.disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [unowned self] idx in
                self.dismiss(animated: true) {
                    self.topVC.openUserProfile(userModel: self.userRelay.value[idx.row])
                }

            })
            .disposed(by: rx.disposeBag)
        

        
    }
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}

final class SearchUserCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var idLabel: UILabel!
    static let reuseId = "searchuserCell"
    
}
