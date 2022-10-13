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
    
    let refresh = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        refresh.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
        tableView.refreshControl = refresh
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
                    let sendMessage = UIAction(title: "댓글 보내기") { _ in
                        //MARK: - Todo 댓글 보내기 Action
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
