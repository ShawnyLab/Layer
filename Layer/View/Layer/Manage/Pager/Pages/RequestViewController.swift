//
//  RequestViewController.swift
//  Layer
//
//  Created by 박진서 on 2022/10/12.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class RequestViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Observable.just(CurrentUserModel.shared.friends.filter { $0.layer == -2 })
            .bind(to: tableView.rx.items(cellIdentifier: "requestCell", cellType: RequestCell.self)) { [unowned self] idx, friendModel, cell in
                
                UserManager.shared.fetch(id: friendModel.uid)
                    .subscribe(onSuccess: { [unowned self] userModel in
                        cell.nameLabel.text = userModel.name
                        cell.idLabel.text = userModel.layerId
                        cell.profileImageView.setImage(url: userModel.profileImageUrl)
                    })
                    .disposed(by: rx.disposeBag)
                
            }
            .disposed(by: rx.disposeBag)
    }
    
    @IBAction func viewSentRequest(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "sentrequestVC") as! SentRequestViewController
        self.present(vc, animated: true)
    }
    
}

final class RequestCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var denyButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    
    var denyButtonHandler: (() -> Void)!
    var acceptButtonHandler: (() -> Void)!
    
    override func awakeFromNib() {
        denyButton.layer.cornerRadius = 13
        denyButton.layer.borderColor = UIColor.black.cgColor
        denyButton.layer.borderWidth = 1
        
        acceptButton.layer.cornerRadius = 13
    }
    
    @IBAction func deny(_ sender: Any) {
        denyButtonHandler!()
    }
    
    @IBAction func accept(_ sender: Any) {
        acceptButtonHandler!()
    }
}
