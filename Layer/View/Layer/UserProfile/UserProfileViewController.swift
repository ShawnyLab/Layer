//
//  UserProfileViewController.swift
//  Layer
//
//  Created by 박진서 on 2022/08/20.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

final class UserProfileViewController: UIViewController {

    static let storyId = "userprofileVC"
    
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    
    @IBOutlet weak var desLabel: UILabel!
    @IBOutlet weak var addFriendButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    
    var userModel: UserModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        makeUI()
        
        profileImageView.setImage(url: userModel.profileImageUrl)
        
        idLabel.text = userModel.layerId
        nameLabel.text = userModel.name
        desLabel.text = userModel.des
        
        cancelButton.isHidden = true
        cancelButton.layer.cornerRadius = 13
        cancelButton.layer.borderWidth = 1
        
        tableView.isHidden = true
        
        addFriendButton.layer.cornerRadius = 13
        
        if isFriend() == -4 {
            addFriendButton.isHidden = true
        } else if isFriend() == -3 {
            buttonDefault()
        } else if isFriend() == -1 {
            buttonRequested()
        } else if isFriend() == -2 {
            buttonAccept()
            cancelButton.isHidden = false
        } else {
            if isFriend() == 0 {
                buttonWhite()
            } else if isFriend() == 1 {
                buttonGray()
            } else if isFriend() == 2 {
                buttonBlack()
            }
            bindTableView()
        }
        
        addFriendButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                
                
                
                if isFriend() == -3 {
                    UserManager.shared.sendFriendRequest(userModel: userModel)
                    addFriendButton.backgroundColor = .white
                    addFriendButton.layer.borderWidth = 1
                    addFriendButton.setTitle("친구신청 대기중...", for: .normal)
                    addFriendButton.setTitleColor(.black, for: .normal)
                
                    cancelButton.isHidden = false
                } else if isFriend() == -2 {
                    print("accept")
                    UserManager.shared.acceptFriendRequest(uid: userModel.uid)
                    
                    addFriendButton.isHidden = true
                }


            })
            .disposed(by: rx.disposeBag)
        
        cancelButton.rx.tap
            .bind { [unowned self] Void in
                UserManager.shared.cancelFriendRequest(uid: userModel.uid)
                
                addFriendButton.backgroundColor = .black
                addFriendButton.setTitleColor(.white, for: .normal)
                addFriendButton.setTitle("친구신청", for: .normal)
                
                cancelButton.isHidden = true

            }
            .disposed(by: rx.disposeBag)
    }
    
    private func makeUI() {
        profileImageView.layer.cornerRadius = 39.5
    }
    
    private func buttonDefault() {
        addFriendButton.isHidden = false
        addFriendButton.backgroundColor = .black
        addFriendButton.layer.borderWidth = 0
        addFriendButton.setTitleColor(UIColor(red: 152, green: 248, blue: 190), for: .normal)
        addFriendButton.setTitle("친구 신청", for: .normal)
    }
    
    private func buttonAccept() {
        addFriendButton.isHidden = false
        addFriendButton.backgroundColor = .black
        addFriendButton.layer.borderWidth = 0
        addFriendButton.setTitleColor(UIColor(red: 152, green: 248, blue: 190), for: .normal)
        addFriendButton.setTitle("친구 수락", for: .normal)
    }
    
    private func buttonRequested() {
        addFriendButton.isHidden = false
        addFriendButton.backgroundColor = .white
        addFriendButton.layer.borderWidth = 1
        addFriendButton.layer.borderColor = UIColor.black.cgColor
        addFriendButton.setTitleColor(.black, for: .normal)
        addFriendButton.setTitle("요청됨", for: .normal)
    }
    
    private func buttonWhite() {
        addFriendButton.isHidden = false
        addFriendButton.backgroundColor = .white
        addFriendButton.layer.borderWidth = 1
        addFriendButton.layer.borderColor = UIColor(red: 153, green: 153, blue: 153).cgColor
        addFriendButton.setTitleColor(UIColor(red: 153, green: 153, blue: 153), for: .normal)
        addFriendButton.setTitle("Layer White", for: .normal)
    }
    
    private func buttonGray() {
        addFriendButton.isHidden = false
        addFriendButton.backgroundColor = UIColor(red: 95, green: 95, blue: 95)
        addFriendButton.layer.borderWidth = 0
        addFriendButton.setTitleColor(.white, for: .normal)
        addFriendButton.setTitle("Layer Gray", for: .normal)
    }
    
    private func buttonBlack() {
        addFriendButton.isHidden = false
        addFriendButton.backgroundColor = .black
        addFriendButton.layer.borderWidth = 0
        addFriendButton.setTitleColor(.white, for: .normal)
        addFriendButton.setTitle("Layer Black", for: .normal)
    }
    
    private func isFriend() -> Int {
        // code -3 : not friend
        
        
        if let friendModel = CurrentUserModel.shared.friends.first(where: {$0.uid == userModel.uid}) {
            return friendModel.layer / 10
        } else if userModel.uid == CurrentUserModel.shared.uid {
            return -4
        }
        
        return -3
    }
    
    private func bindTableView() {
        tableView.isHidden = false
        
        tableView.rx.setDelegate(self)
            .disposed(by: rx.disposeBag)
        
        Observable.just(userModel.frameArray)
            .bind(to: tableView.rx.items(cellIdentifier: FriendFrameCell.reuseId, cellType: FriendFrameCell.self)) { idx, frameModel, cell in
                cell.frameTitleLabel.text = frameModel.title
                if let imageUrl = frameModel.imageUrl {
                    cell.frameImageView.isHidden = false
                    cell.frameImageView.setImage(url: frameModel.imageUrl)
                } else {
                    cell.frameImageView.isHidden = true
                }
            }
            .disposed(by: rx.disposeBag)
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    

}

extension UserProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

final class FriendFrameCell: UITableViewCell {
    static let reuseId = "friendframeCell"
    
    @IBOutlet weak var frameImageView: UIImageView!
    @IBOutlet weak var frameTitleLabel: UILabel!
    
    
    
    
}
