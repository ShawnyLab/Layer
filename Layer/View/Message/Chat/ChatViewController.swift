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
    
    @IBOutlet weak var tempButton: UIButton!
    
    @IBOutlet weak var frameView: UIView!
    @IBOutlet weak var frameTitleLabel: UILabel!
    @IBOutlet weak var frameImageView: UIImageView!
    @IBOutlet weak var frameContentLabel: UILabel!
    
    var frameModel: FrameModel?
    var userModel: UserModel!
    var chatArray: [ChatModel] = []
    private var isTemp = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let frameModel {
            frameView.isHidden = false
            if let imageUrl = frameModel.imageUrl {
                frameContentLabel.isHidden = true
                frameImageView.isHidden = false
                frameImageView.setImage(url: imageUrl)
                
                frameTitleLabel.text = frameModel.createdAt
            } else {
                frameImageView.isHidden = true
                frameContentLabel.isHidden = false
                frameContentLabel.text = frameModel.content
                frameTitleLabel.text = frameModel.title
            }
        } else {
            frameView.isHidden = true
        }
        
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
                if !chatArray.isEmpty {
                    tableView.scrollToRow(at: [0, chatArray.count-1], at: .bottom, animated: true)
                }
                
            })
            .disposed(by: rx.disposeBag)
        
        tableView.delegate = self
        tableView.dataSource = self
        

        
        sendButton.rx.tap
            .bind { [unowned self] Void in
                let chatModel = ChatManager.shared.send(userId: userModel.uid, message: messageTextfield.text ?? "", isTemp: isTemp, frameModel: frameModel)
                messageTextfield.text = nil
                if self.chatArray.isEmpty {
                    ChatManager.shared.createChatRoom(userId: userModel.uid)
                }
                if frameModel != nil {
                    self.frameView.isHidden = true
                    self.frameModel = nil
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
        
        tempButton.rx.tap
            .bind { [unowned self] _ in
                if isTemp {
                    tempButton.setTitle(" 사라지지 않는 메시지", for: .normal)
                    tempButton.tintColor = UIColor(red: 248, green: 152, blue: 152)
                    tempButton.setTitleColor(UIColor(red: 248, green: 152, blue: 152), for: .normal)
                    isTemp = false
                } else {
                    tempButton.setTitle(" 1시간 뒤 사라지는 메세지", for: .normal)
                    tempButton.tintColor = UIColor(red: 217, green: 217, blue: 217)
                    tempButton.setTitleColor(UIColor(red: 153, green: 153, blue: 153), for: .normal)
                    isTemp = true
                }
            }
            .disposed(by: rx.disposeBag)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillShowNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        let keyboardHeight = keyboardFrame.height
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.bottomView.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight)
            self?.frameView.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight)
        }
        
        
    }
    
    @objc func keyboardWillHideNotification(_ notification: Notification) {
        bottomView.transform = .identity
        frameView.transform = .identity
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
            
            if let frameModel = chatArray[indexPath.row].frameModel {
                cell.frameView.isHidden = false

                if let imageUrl = frameModel.imageUrl {
                    cell.frameImageView.isHidden = false
                    cell.frameImageView.setImage(url: imageUrl)
                    cell.frameContentlabel.isHidden = true
                } else {
                    cell.frameImageView.isHidden = true
                    cell.frameContentlabel.isHidden = false
                    cell.frameContentlabel.text = frameModel.content

                }
                cell.frameTitleLabel.text = frameModel.title

            } else {
                cell.frameImageView.image = nil
                cell.frameView.isHidden = true
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "yourCell", for: indexPath) as! YourChatTableViewCell
            cell.profileImageView.image = self.profileImageView.image
            cell.messageLabel.text = chatArray[indexPath.row].message
            
            if let frameModel = chatArray[indexPath.row].frameModel {
                cell.frameView.isHidden = false

                if let imageUrl = frameModel.imageUrl {
                    cell.frameImageView.isHidden = false
                    cell.frameImageView.setImage(url: imageUrl)
                    cell.frameContentLabel.isHidden = true
                } else {
                    cell.frameImageView.isHidden = true
                    cell.frameContentLabel.isHidden = false
                    cell.frameContentLabel.text = frameModel.content

                }
                cell.frameTitleLabel.text = frameModel.title

            } else {
                cell.frameImageView.image = nil
                cell.frameView.isHidden = true
            }
            return cell
        }
    }
    
}
