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
    static let storyId = "messageVC"

    override func viewDidLoad() {
        super.viewDidLoad()

        Observable.just(CurrentUserModel.shared.friends.filter{$0.layer >= 0})
            .bind(to: friendCollectionView.rx.items(cellIdentifier: FriendCell.reuseId, cellType: FriendCell.self)) { idx, friendModel, cell in
                
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
        makeUI()
    }
    
    private func makeUI() {
        searchBarContainer.layer.cornerRadius = 13
    }
}

extension MessageViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 65, height: 80)
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
