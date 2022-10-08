//
//  UserProfileViewController.swift
//  Layer
//
//  Created by 박진서 on 2022/08/20.
//

import UIKit

final class UserProfileViewController: UIViewController {

    static let storyId = "userprofileVC"
    
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var desLabel: UILabel!
    @IBOutlet weak var addFriendButton: UIButton!
    
    
    
    var userModel: UserModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        makeUI()
        
        profileImageView.setImage(url: userModel.profileImageUrl)
        
        nameLabel.text = userModel.name
        desLabel.text = userModel.des
        
        addFriendButton.layer.cornerRadius = 13
        addFriendButton.layer.borderWidth = 0
        addFriendButton.layer.borderColor = UIColor.black.cgColor
        
        if isFriend() == 0 {
        } else if isFriend() == -1 {
            addFriendButton.backgroundColor = .white
            addFriendButton.layer.borderWidth = 1
            addFriendButton.setTitle("친구신청 대기중...", for: .normal)
            addFriendButton.setTitleColor(.black, for: .normal)
        } else if isFriend() == -2 {
            addFriendButton.setTitle("친구 수락", for: .normal)
            addFriendButton.setTitleColor(.white, for: .normal)
        } else {
            addFriendButton.isHidden = true
            bindTableView()
        }
        
        addFriendButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                if isFriend() == 0 {
                    UserManager.shared.sendFriendRequest(userModel: userModel)
                    addFriendButton.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
                    addFriendButton.setTitle("친구신청 대기중...", for: .normal)
                    addFriendButton.layer.borderWidth = 1
                    addFriendButton.setTitleColor(.black, for: .normal)
                } else if isFriend() == -2 {
                    
                }
            
            })
            .disposed(by: rx.disposeBag)
    }
    
    private func makeUI() {
        profileImageView.layer.cornerRadius = 39.5
    }
    
    private func isFriend() -> Int {
        for friend in CurrentUserModel.shared.friends {
            if friend.uid == userModel.uid {
                return friend.layer
            }
        }
        return 0
    }
    
    private func bindTableView() {
        
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    

}
