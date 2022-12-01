//
//  ProfileViewController.swift
//  Layer
//
//  Created by 박진서 on 2022/07/27.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import PhotosUI

final class ProfileViewController: UIViewController {
    static let storyId = "profileVC"

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var desLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    let layerRelay = BehaviorRelay<LayerType>(value: .white)
    
    private let frameRelay = BehaviorRelay<[SimpleFrameModel]>(value: CurrentUserModel.shared.frameModels)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        profileImageView.setImage(url: CurrentUserModel.shared.profileImageUrl)
        idLabel.text = CurrentUserModel.shared.layerId
        desLabel.text = CurrentUserModel.shared.des
        nameLabel.text = CurrentUserModel.shared.name
        
        frameRelay.accept(CurrentUserModel.shared.frameModels)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicator.isHidden = true
        profileImageView.layer.cornerRadius = 39.5
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80

        
       frameRelay
            .bind(to: tableView.rx.items(cellIdentifier: MyFrameCell.reuseId, cellType: MyFrameCell.self)) { [unowned self] idx, simpleFrameModel, cell in
                if idx == CurrentUserModel.shared.frameModels.count-1 {
                    cell.barView.isHidden = true
                } else {
                    cell.barView.isHidden = false
                }
                
                if idx == 0 {
                    cell.topBarView.isHidden = true
                } else {
                    cell.topBarView.isHidden = false
                }
                
                cell.titleLabel.text = simpleFrameModel.title
                if let imgUrl = simpleFrameModel.imageUrl {
                    cell.contentImageView.setImage(url: imgUrl)
                } else {
                    cell.contentImageView.isHidden = true
                }
                
                cell.greydot.layer.cornerRadius = 4
                var splited = simpleFrameModel.createdAt.split(separator: "T").map{String($0)}
                cell.dateLabel.text = splited[0]
                
                layerRelay
                    .subscribe(onNext: { [unowned self] layer in
                        switch layer {
                        case .white:
                            cell.backgroundColor = .white
                            cell.titleLabel.textColor = .black
                        case .black:
                            cell.backgroundColor = .black
                            cell.titleLabel.textColor = .white

                        case .gray:
                            cell.backgroundColor = .white
                            cell.titleLabel.textColor = .black

                        }
                    })
                    .disposed(by: rx.disposeBag)
            }
            .disposed(by: rx.disposeBag)
        
        
        layerRelay
            .subscribe(onNext: { [unowned self] layer in
                switch layer {
                case .white:
                    self.view.backgroundColor = .white
                    tableView.backgroundColor = .white
                    idLabel.textColor = .black
                    nameLabel.textColor = .black
                    desLabel.textColor = .black
                    
                    break
                case .black:
                    self.view.backgroundColor = .black
                    tableView.backgroundColor = .black
                    idLabel.textColor = .white
                    nameLabel.textColor = .white
                    desLabel.textColor = .white

                    break
                case .gray:
                    self.view.backgroundColor = .white
                    tableView.backgroundColor = .white
                    idLabel.textColor = .black
                    nameLabel.textColor = .black
                    desLabel.textColor = .black

                    break
                }
            })
            .disposed(by: rx.disposeBag)
    }
    

}


final class MyFrameCell: UITableViewCell {
    static let reuseId = "myframeCell"
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var greydot: UIView!
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var barView: UIView!
    @IBOutlet weak var topBarView: UIView!
    
}
