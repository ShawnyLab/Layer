//
//  ChangeFinalViewController.swift
//  Layer
//
//  Created by 박진서 on 2022/11/12.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

final class ChangeFinalViewController: UIViewController {
    static let storyId = "changefinalVC"
    
    var layerStatus: LayerType!
    var userModel: UserModel!
    var topVC: ChangeLayerViewController!

    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var subLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var reselectButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    private let toShowRelay = BehaviorRelay<[FriendModel]>(value: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reselectButton.layer.cornerRadius = 13
        doneButton.layer.cornerRadius = 13
        
        reselectButton.layer.borderColor = UIColor.black.cgColor
        reselectButton.layer.borderWidth = 1

        idLabel.text = userModel.layerId
        // Do any additional setup after loading the view.
        switch layerStatus {
        case .black:
            subLabel.text = "레이어 BLACK에 배치"
            toShowRelay.accept(CurrentUserModel.shared.friends.filter({$0.layer/10 == 2 && $0.uid != userModel.uid}))
        case .gray:
            subLabel.text = "레이어 GRAY에 배치"
            toShowRelay.accept(CurrentUserModel.shared.friends.filter({$0.layer/10 == 1 && $0.uid != userModel.uid}))

        case .white:
            subLabel.text = "레이어 WHITE에 배치"
            toShowRelay.accept(CurrentUserModel.shared.friends.filter({$0.layer/10 == 0 && $0.uid != userModel.uid}))

        case .none:
            break
        }
        
        reselectButton.rx.tap
            .bind { _ in
                self.dismiss(animated: true)
            }
            .disposed(by: rx.disposeBag)
        
        doneButton.rx.tap
            .bind { [unowned self] _ in
                UserManager.shared.changeLayer(userModel: userModel, layer: layerStatus)
                self.dismiss(animated: true) {
                    self.topVC.dismiss(animated: true)
                    self.topVC.reload!()
                }
            }
            .disposed(by: rx.disposeBag)
        
        toShowRelay
            .bind(to: tableView.rx.items(cellIdentifier: LayerFriendListCell.reuseId, cellType: LayerFriendListCell.self)) { idx, friendModel, cell in
                UserManager.shared.fetch(id: friendModel.uid)
                    .subscribe(onSuccess: { userModel in
                        if let url = userModel.profileImageUrl {
                            cell.profileImageView.setImage(url: url)
                        } else {
                            cell.profileImageView.image = nil
                        }
                        
                        cell.idLabel.text = userModel.layerId
                    }) { error in
                        print(error)
                    }
                    .disposed(by: self.rx.disposeBag)
            }
            .disposed(by: rx.disposeBag)
        

        
        tableView.rx.setDelegate(self)
            .disposed(by: rx.disposeBag)
    }

}

extension ChangeFinalViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

final class LayerFriendListCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var idLabel: UILabel!
    static let reuseId = "lflCell"
    
    override func awakeFromNib() {
        profileImageView.circular()
    }
}
