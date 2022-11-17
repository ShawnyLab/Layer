//
//  LayerViewController.swift
//  Layer
//
//  Created by 박진서 on 2022/07/27.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class LayerViewController: UIViewController {
    static let storyId = "layerVC"

    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet var viewModel: LayerViewModel!
    @IBOutlet weak var tableView: UITableView!
    
    
    let layerRelay = BehaviorRelay<LayerType>(value: .white)
    private let refresh = UIRefreshControl()
    private var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        refresh.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
        tableView.refreshControl = refresh
        
        layerRelay.subscribe(onNext: { [unowned self] layer in
            switch layer {
            case .white:
                self.view.backgroundColor = .white
                self.tableView.backgroundColor = .white
            case .black:
                self.view.backgroundColor = .black
                self.tableView.backgroundColor = .black
            case .gray:
                self.view.backgroundColor = .layerGray
                self.tableView.backgroundColor = .layerGray
                
            }
        })
        .disposed(by: rx.disposeBag)
    }
    
    @objc func pullToRefresh(_ sender: Any) {
        FrameManager.shared.fetchFirst()
            .subscribe {
                print("fetch")
                self.refresh.endRefreshing()
            } onError: { err in
                print(err)
                self.refresh.endRefreshing()

            }
            .disposed(by: rx.disposeBag)

    }

    
    private func bind() {
        indicator.isHidden = true
        indicator.stopAnimating()

        tableView.rx.setDelegate(self)
            .disposed(by: rx.disposeBag)
        
        viewModel
            .frameRelay
            .bind(to: tableView.rx.items(cellIdentifier: FrameTableViewCell.reuseId, cellType: FrameTableViewCell.self)) { idx, frameModel, cell in
                cell.bind(frameModel: frameModel)
                
                UserManager.shared.fetch(id: frameModel.writerId)
                    .subscribe(onSuccess: { [unowned self] userModel in
                        cell.nameLabel.text = userModel.layerId
                        if userModel.profileImageUrl != nil {
                            cell.profileImageView.setImage(url: userModel.profileImageUrl)
                        } else {
                            cell.profileImageView.image = nil
                        }
                    })
                    .disposed(by: self.rx.disposeBag)
                
                self.layerRelay
                    .subscribe(onNext: { layer in
                        switch layer {
                        case .white:
                            cell.profileImageView.backgroundColor = .black
                            cell.dueLabel.textColor = .black
                            cell.contentLabel.textColor = .black
                            cell.nameLabel.textColor = .black
                            cell.titleLabel.textColor = .black
                            cell.backgroundColor = .white
                            cell.optionBtn.setImage(UIImage(named: "elipsisBlack"), for: .normal)
                        case .black:
                            cell.profileImageView.backgroundColor = .white
                            cell.dueLabel.textColor = .white
                            cell.contentLabel.textColor = .white
                            cell.nameLabel.textColor = .white
                            cell.titleLabel.textColor = .white
                            cell.backgroundColor = .black
                            cell.optionBtn.setImage(UIImage(named: "elipsisWhite"), for: .normal)
                        case .gray:
                            cell.profileImageView.backgroundColor = .black
                            cell.dueLabel.textColor = .black
                            cell.contentLabel.textColor = .black
                            cell.nameLabel.textColor = .black
                            cell.titleLabel.textColor = .black
                            cell.backgroundColor = .layerGray
                            cell.optionBtn.setImage(UIImage(named: "elipsisBlack"), for: .normal)
                        }
                    })
                    .disposed(by: self.rx.disposeBag)
                
                
                
                let changeLayer = UIAction(title: "공개 범위 변경") { _ in
                    //MARK: - Todo 공개 범위 변경 Action
                }
                
                if frameModel.writerId == CurrentUserModel.shared.uid {
                    //My Frame
                    let edit = UIAction(title: "프레임 수정") { _ in
                        //MARK: - Todo 프레임 수정 Action
                    }

                    let delete = UIAction(title: "프레임 삭제", attributes: .destructive) { [unowned self] _ in
                        //MARK: - Todo 프레임 삭제 Action
                        indicator.isHidden = false
                        indicator.startAnimating()
                        FrameManager.shared.delete(uid: frameModel.uid)
                            .subscribe { [unowned self] in
                                indicator.isHidden = true
                                indicator.stopAnimating()
                                
//                                viewModel.reload()
                            }
                            .disposed(by: rx.disposeBag)
                    }
                    
                    cell.optionBtn.menu = UIMenu(children: [edit, changeLayer, delete])
                } else {
                    let sendMessage = UIAction(title: "댓글 보내기") { [unowned self] _ in
                        indicator.isHidden = false
                        indicator.startAnimating()
                        
                        UserManager.shared.fetch(id: frameModel.writerId)
                            .subscribe { [unowned self] userModel in
                                let vc = UIStoryboard(name: "Message", bundle: nil).instantiateViewController(withIdentifier: "chatVC") as! ChatViewController
                                vc.userModel = userModel
                                vc.frameModel = frameModel
                                indicator.isHidden = true
                                indicator.stopAnimating()
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                            .disposed(by: rx.disposeBag)

                    }
                    cell.optionBtn.menu = UIMenu(children: [sendMessage, changeLayer])
                }
                cell.optionBtn.showsMenuAsPrimaryAction = true

            }
            .disposed(by: rx.disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [unowned self] idx in
                tableView.deselectRow(at: idx, animated: true)
                indicator.isHidden = false
                indicator.startAnimating()
                
                viewModel.fetchUserModel(idx: idx.row)
                    .subscribe { [unowned self] userModel in
                        print(userModel.uid)
                        
                        AuthManager.shared.fetchFriend()
                            .subscribe(onCompleted: { [unowned self] in
                                userProfileVC(userModel: userModel)
                                indicator.isHidden = true
                                indicator.stopAnimating()
                            }) { error in
                                print(error)
                            }
                            .disposed(by: rx.disposeBag)


                    } onError: { [unowned self] error in
                        print(error)
                        indicator.isHidden = true
                        indicator.stopAnimating()
                    }
                    .disposed(by: rx.disposeBag)
                    
                    

            })
            .disposed(by: rx.disposeBag)
        
        tableView.rx.didScroll
            .subscribe(onNext: { [unowned self] in
                
                // Stack OverFlow https://stackoverflow.com/questions/39015228/detect-when-uitableview-has-scrolled-to-the-bottom
                
                if !isLoading {
                    
                    let height = tableView.frame.size.height
                    let contentYOffset = tableView.contentOffset.y
                    let distanceFromBottom = tableView.contentSize.height - contentYOffset
                    
                    if distanceFromBottom < height {
                        isLoading = true
                        indicator.isHidden = false
                        indicator.startAnimating()
                        
                        viewModel.fetchMore()
                            .subscribe(onCompleted: { [unowned self] in
                                indicator.isHidden = true
                                indicator.stopAnimating()
                                
                                isLoading = false
                            }, onError: { [unowned self] error in
                                print(error)
                                indicator.isHidden = true
                                indicator.stopAnimating()
                                
                                isLoading = false

                            })
                            .disposed(by: rx.disposeBag)
                    }
                }
                

            })
            .disposed(by: rx.disposeBag)
    }

    private func userProfileVC(userModel: UserModel) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "userprofileVC") as! UserProfileViewController
        vc.userModel = userModel
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension LayerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
