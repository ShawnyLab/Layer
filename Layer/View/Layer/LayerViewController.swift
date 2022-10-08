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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()

    }

    
    private func bind() {
        indicator.isHidden = true
        indicator.stopAnimating()

        tableView.rowHeight = UITableView.automaticDimension
        
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
                        userProfileVC(userModel: userModel)

                        indicator.isHidden = true
                        indicator.stopAnimating()
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
