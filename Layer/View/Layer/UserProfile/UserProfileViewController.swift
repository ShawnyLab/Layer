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
    @IBOutlet weak var idLabel: UILabel!
    
    @IBOutlet weak var desLabel: UILabel!
    @IBOutlet weak var addFriendButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    
    var userModel: UserModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        makeUI()
        
        profileImageView.setImage(url: userModel.profileImageUrl)
        
        idLabel.text = userModel.layerId
        nameLabel.text = userModel.name
        desLabel.text = userModel.des
        
        addFriendButton.layer.cornerRadius = 13
        addFriendButton.layer.borderWidth = 0
        addFriendButton.layer.borderColor = UIColor.black.cgColor
        
        cancelButton.isHidden = true
        
        print(isFriend())
        
        if isFriend() == -3 {
            
        } else if isFriend() == -1 {
            addFriendButton.backgroundColor = .white
            addFriendButton.layer.borderWidth = 1
            addFriendButton.setTitle("친구신청 대기중...", for: .normal)
            addFriendButton.setTitleColor(.black, for: .normal)
            
            cancelButton.isHidden = false
        } else if isFriend() == -2 {
            addFriendButton.setTitle("친구 수락", for: .normal)
            addFriendButton.setTitleColor(.white, for: .normal)
        } else {
            print("else")
            addFriendButton.isHidden = true
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
    
    private func isFriend() -> Int {
        // code -3 : not friend
        
        
        if let friendModel = CurrentUserModel.shared.friends.first(where: {$0.uid == userModel.uid}) {
            return friendModel.layer
        }
        return -3
    }
    
    private func bindTableView() {
        
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    

}
