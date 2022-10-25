//
//  ChatViewController.swift
//  Layer
//
//  Created by 박진서 on 2022/10/13.
//

import UIKit

class ChatViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    
    @IBOutlet weak var messageTextfield: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var textfieldView: UIView!
    
    
    var userModel: UserModel!
    var chatArray: [ChatModel] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = userModel.name
        idLabel.text = userModel.layerId
        
        profileImageView.layer.cornerRadius = 20
        
        if let url = userModel.profileImageUrl {
            profileImageView.setImage(url: url)

        } else {
            profileImageView.image = nil
        }
        
        ChatManager.shared.enterChatRoom(userId: userModel.uid)
            .subscribe(onNext: { [unowned self] chatArray in
                //Todo - indicator
                self.chatArray = chatArray
                self.tableView.reloadData()
                
            })
            .disposed(by: rx.disposeBag)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        sendButton.rx.tap
            .bind { [unowned self] Void in
                let chatModel = ChatManager.shared.send(userId: userModel.uid, message: messageTextfield.text ?? "", isTemp: false)
                messageTextfield.text = nil
                if self.chatArray.isEmpty {
                    ChatManager.shared.createChatRoom(userId: userModel.uid)
                }
                self.chatArray.append(chatModel)

                tableView.reloadData()
            }
            .disposed(by: rx.disposeBag)
        
        textfieldView.layer.cornerRadius = 13
        textfieldView.layer.borderWidth = 1
        textfieldView.layer.borderColor = UIColor.black.cgColor
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        

    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillShowNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        let keyboardHeight = keyboardFrame.height
        
        self.bottomView.isHidden = false
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.bottomView.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight)
        }
        
        
    }
    
    @objc func keyboardWillHideNotification(_ notification: Notification) {
        bottomView.transform = .identity
    }
    
    func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    @IBAction func popAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if chatArray[indexPath.row].userId == CurrentUserModel.shared.uid {
            let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! MyChatTableViewCell
            
            cell.messageLabel.text = chatArray[indexPath.row].message
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "yourCell", for: indexPath) as! YourChatTableViewCell
            cell.profileImageView.image = self.profileImageView.image
            cell.messageLabel.text = chatArray[indexPath.row].message
            return cell
        }
    }
    
}
