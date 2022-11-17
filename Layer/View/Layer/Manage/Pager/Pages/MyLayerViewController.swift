//
//  MyLayerViewController.swift
//  Layer
//
//  Created by 박진서 on 2022/10/12.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class MyLayerViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var countLabel: UILabel!
    
    private let friendArray = BehaviorRelay(value: CurrentUserModel.shared.friends.filter { $0.layer >= 0 })
    private let refresh = UIRefreshControl()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AuthManager.shared.fetchFriend()
            .subscribe {
                self.friendArray.accept(CurrentUserModel.shared.friends.filter { $0.layer >= 0 })
            }
            .disposed(by: rx.disposeBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        refresh.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
        
        tableView.refreshControl = refresh
        tableView.rx.setDelegate(self)
            .disposed(by: rx.disposeBag)

        friendArray.map { "내 모든 레이어 보기 (\($0.count))" }
            .bind(to: countLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        friendArray
            .bind(to: tableView.rx.items(cellIdentifier: "mylayerCell", cellType: MyLayerCell.self)) { [unowned self] idx, friendModel, cell in
                
                if friendModel.layer/10 == 0 {
                    cell.layerLabel.text = "Layer White"
                    cell.layerLabel.textColor = UIColor(red: 153, green: 153, blue: 153)
                    cell.layerLabel.layer.borderWidth = 1
                    cell.layerLabel.layer.borderColor = UIColor(red: 153, green: 153, blue: 153).cgColor
                    cell.layerLabel.backgroundColor = .white
                } else if friendModel.layer/10 == 1 {
                    cell.layerLabel.text = "Layer Gray"
                    cell.layerLabel.textColor = .white
                    cell.layerLabel.backgroundColor = UIColor(red: 95, green: 95, blue: 95)
                    cell.layerLabel.layer.borderWidth = 0
                } else if friendModel.layer/10 == 2 {
                    cell.layerLabel.text = "Layer Black"
                    cell.layerLabel.textColor = .white
                    cell.layerLabel.backgroundColor = .black
                    cell.layerLabel.layer.borderWidth = 0
                }
                
                
                UserManager.shared.fetch(id: friendModel.uid)
                    .subscribe(onSuccess: { userModel in
                        cell.nameLabel.text = userModel.name
                        cell.idLabel.text = userModel.layerId
                        cell.profileImageView.setImage(url: userModel.profileImageUrl)
                        
                        cell.changeButtonHandler = {
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: ChangeLayerViewController.storyId) as! ChangeLayerViewController
                            let nav = UINavigationController(rootViewController: vc)
                            nav.modalPresentationStyle = .fullScreen
                            nav.navigationBar.isHidden = true
                            vc.userModel = userModel
                            
                            self.present(nav, animated: true)
                        }
                    })
                    .disposed(by: rx.disposeBag)
            }
            .disposed(by: rx.disposeBag)
    }
    
    @objc func pullToRefresh(_ sender: Any) {
        AuthManager.shared.fetchFriend()
            .subscribe {
                print("completed")
                self.refresh.endRefreshing()
                self.friendArray.accept(CurrentUserModel.shared.friends.filter { $0.layer >= 0 })
            }
            .disposed(by: rx.disposeBag)
    }

}

extension MyLayerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 71
    }
}

final class MyLayerCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var layerLabel: UILabel!
    
    var changeButtonHandler: (() -> Void)!
    
    override func awakeFromNib() {
        changeButton.layer.cornerRadius = 13
        changeButton.layer.borderColor = UIColor.black.cgColor
        changeButton.layer.borderWidth = 1
        
        layerLabel.layer.cornerRadius = 13
        layerLabel.layer.borderColor = UIColor(red: 153, green: 153, blue: 153).cgColor
        layerLabel.layer.borderWidth = 1
        
        profileImageView.layer.cornerRadius = 20
    }
    
    @IBAction func changeLayer(_ sender: Any) {
        changeButtonHandler!()
    }
    
    
}
