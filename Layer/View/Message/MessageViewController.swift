//
//  MessageViewController.swift
//  Layer
//
//  Created by 박진서 on 2022/07/27.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

final class MessageViewController: UIViewController {
    
    @IBOutlet weak var searchBarContainer: UIView!
    @IBOutlet weak var friendCollectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var availableLabel: UILabel!
    
    static let storyId = "messageVC"
    
    let layerRelay = BehaviorRelay<LayerType>(value: .white)
    
    private let friendModelArray = BehaviorRelay<[FriendModel]>(value: CurrentUserModel.shared.friends.filter{$0.layer >= 0})
    
    private let chatRoomArray = BehaviorRelay<[ChatRoomModel]>(value: [])

    override func viewDidLoad() {
        super.viewDidLoad()

        indicator.isHidden = true
        friendModelArray
            .bind(to: friendCollectionView.rx.items(cellIdentifier: FriendCell.reuseId, cellType: FriendCell.self)) { [unowned self] idx, friendModel, cell in
                
                
                layerRelay
                    .subscribe(onNext: { [unowned self] layer in
                        switch layer {
                        case .white:
                            cell.profileImageView.backgroundColor = .black
                            cell.nameLabel.textColor = .black
                        case .black:
                            cell.profileImageView.backgroundColor = .white
                            cell.nameLabel.textColor = .white
                            
                        case .gray:
                            cell.profileImageView.backgroundColor = .black
                            cell.nameLabel.textColor = .black
                        }
                    })
                    .disposed(by: rx.disposeBag)
                
                UserManager.shared.fetch(id: friendModel.uid)
                    .subscribe(onSuccess: { userModel in
                        if let url = userModel.profileImageUrl {
                            cell.profileImageView.setImage(url: url)
                        } else {
                            cell.profileImageView.image = nil
                        }

                        cell.nameLabel.text = userModel.layerId
                    }) { error in
                        print(error)
                    }
                    .disposed(by: self.rx.disposeBag)

            }
            .disposed(by: rx.disposeBag)
            
        
        friendCollectionView.rx.setDelegate(self)
            .disposed(by: rx.disposeBag)
        
        friendCollectionView.rx.itemSelected
            .subscribe(onNext: { [unowned self] idx in
                indicator.isHidden = false
                indicator.startAnimating()
                
                UserManager.shared.fetch(id: friendModelArray.value[idx.row].uid)
                    .subscribe(onSuccess: { [unowned self] userModel in
                        
                        
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "chatVC") as! ChatViewController
                        vc.userModel = userModel
                        
                        indicator.isHidden = true
                        indicator.stopAnimating()
                        
                        self.navigationController?.pushViewController(vc, animated: true)
                        
                    })
                    .disposed(by: rx.disposeBag)
            })
            .disposed(by: rx.disposeBag)
        
        ChatManager.shared.fetchRooms()
            .bind(to: chatRoomArray)
            .disposed(by: rx.disposeBag)
        
        chatRoomArray
            .bind(to: tableView.rx.items(cellIdentifier: "chatroomCell", cellType: ChatRoomCell.self)) { [unowned self] idx, roomModel, cell in
                let otherUserId = roomModel.otherUserId()
                
                layerRelay
                    .subscribe(onNext: { [unowned self] layer in
                        switch layer {
                        case .white:
                            cell.backgroundColor = .white
                            cell.profileImageView.backgroundColor = .black
                            cell.idLabel.textColor = .black
                            cell.messageLabel.textColor = .black
                        case .black:
                            cell.backgroundColor = .black
                            cell.profileImageView.backgroundColor = .white
                            cell.idLabel.textColor = .white
                            cell.messageLabel.textColor = .white

                        case .gray:
                            cell.backgroundColor = .layerGray
                            cell.profileImageView.backgroundColor = .black
                            cell.idLabel.textColor = .black
                            cell.messageLabel.textColor = .black

                        }
                    })
                    .disposed(by: rx.disposeBag)
                
                UserManager.shared.fetch(id: otherUserId)
                    .subscribe(onSuccess: { userModel in
                        if let url = userModel.profileImageUrl {
                            cell.profileImageView.setImage(url: url)
                        } else {
                            cell.profileImageView.image = nil
                        }

                        cell.idLabel.text = userModel.layerId
                        cell.messageLabel.text = roomModel.lastMessage?.message
                        
                    }) { error in
                        print(error)
                    }
                    .disposed(by: self.rx.disposeBag)

                
            }
            .disposed(by: rx.disposeBag)
        
        tableView.rx.setDelegate(self)
            .disposed(by: rx.disposeBag)
        
        tableView.rx.itemSelected
            .subscribe { [unowned self] idx in
                indicator.isHidden = false
                indicator.startAnimating()
                
                tableView.deselectRow(at: idx, animated: true)
                
                UserManager.shared.fetch(id: chatRoomArray.value[idx.row].otherUserId())
                    .subscribe(onSuccess: { [unowned self] userModel in
                        
                        
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "chatVC") as! ChatViewController
                        vc.userModel = userModel
                        
                        indicator.isHidden = true
                        indicator.stopAnimating()
                        
                        self.navigationController?.pushViewController(vc, animated: true)
                        
                    })
                    .disposed(by: rx.disposeBag)
            }
            .disposed(by: rx.disposeBag)
        
        makeUI()
    }
    
    private func makeUI() {
        searchBarContainer.layer.cornerRadius = 13
        
        layerRelay
            .subscribe(onNext: { [unowned self] layer in
                switch layer {
                case .white:
                    self.view.backgroundColor = .white
                    friendCollectionView.backgroundColor = .white
                    availableLabel.textColor = .black
                    tableView.backgroundColor = .white
                    break
                case .black:
                    self.view.backgroundColor = .black
                    friendCollectionView.backgroundColor = .black
                    availableLabel.textColor = .white
                    tableView.backgroundColor = .black
                    break
                case .gray:
                    self.view.backgroundColor = .layerGray
                    friendCollectionView.backgroundColor = .layerGray
                    availableLabel.textColor = .black
                    tableView.backgroundColor = .layerGray
                    break
                }
            })
            .disposed(by: rx.disposeBag)
    }
}

extension MessageViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 65, height: 80)
    }
}

extension MessageViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 71
    }
}

class FriendCell: UICollectionViewCell {
    static let reuseId = "friendCell"
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    override func awakeFromNib() {
        profileImageView.layer.cornerRadius = 32.5
    }
}

final class ChatRoomCell: UITableViewCell {
    static let reuseId = "chatroomCell"
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        profileImageView.layer.cornerRadius = 20
    }
}
