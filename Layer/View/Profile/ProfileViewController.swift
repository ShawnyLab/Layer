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
    
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    let layerRelay = BehaviorRelay<LayerType>(value: .white)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicator.isHidden = true
        profileImageView.layer.cornerRadius = 39.5
        
        profileImageView.setImage(url: CurrentUserModel.shared.profileImageUrl)
        idLabel.text = CurrentUserModel.shared.layerId
        desLabel.text = CurrentUserModel.shared.des
        nameLabel.text = CurrentUserModel.shared.name
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80

        
        Observable.just(CurrentUserModel.shared.frameModels)
            .bind(to: tableView.rx.items(cellIdentifier: MyFrameCell.reuseId, cellType: MyFrameCell.self)) { [unowned self] idx, simpleFrameModel, cell in
                if idx == CurrentUserModel.shared.frameModels.count-1 {
                    cell.barView.isHidden = true
                } else {
                    cell.barView.isHidden = false
                }
                
                cell.titleLabel.text = simpleFrameModel.title
                if let imgUrl = simpleFrameModel.imageUrl {
                    cell.contentImageView.setImage(url: imgUrl)
                } else {
                    cell.contentImageView.isHidden = true
                }
                
                cell.greydot.layer.cornerRadius = 4
                
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
                            cell.backgroundColor = .layerGray
                            cell.titleLabel.textColor = .black

                        }
                    })
                    .disposed(by: rx.disposeBag)
            }
            .disposed(by: rx.disposeBag)
        
        
        imageButton.rx.tap
            .bind { Void in
                self.presentAlbum()
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
                    self.view.backgroundColor = .layerGray
                    tableView.backgroundColor = .layerGray
                    idLabel.textColor = .black
                    nameLabel.textColor = .black
                    desLabel.textColor = .black

                    break
                }
            })
            .disposed(by: rx.disposeBag)
    }
    
    func presentAlbum() {
        
        var configuration = PHPickerConfiguration() // 1.
        configuration.selectionLimit = 1 // 2.
        configuration.filter = .images // 3.
        let picker = PHPickerViewController(configuration: configuration)

        picker.delegate = self
        
        self.present(picker, animated: true)
    }
    

}

extension ProfileViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) { // 2.
        picker.dismiss(animated: true, completion: nil) // 3.
        
        let itemProvider = results.first?.itemProvider // 4.
        if let itemProvider = itemProvider,
           itemProvider.canLoadObject(ofClass: UIImage.self) { // 5.
            itemProvider.loadObject(ofClass: UIImage.self) { image, error in // 6.
                DispatchQueue.main.async {
                    guard let selectedImage = image as? UIImage else { return }
                    self.profileImageView.image = selectedImage
                    
                    self.indicator.isHidden = false
                    self.indicator.startAnimating()
                    
                    CurrentUserModel.shared.uploadImageOnStorage(image: selectedImage) {
                        self.indicator.isHidden = true
                        self.indicator.stopAnimating()
                    }
                }
            }
        }
        
        //Picker View Source https://velog.io/@wannabe_eung/%EC%95%A8%EB%B2%94%EC%9D%98-%EC%9D%B4%EB%AF%B8%EC%A7%80%EB%A5%BC-%EC%84%A0%ED%83%9D%ED%95%A0-%EC%88%98-%EC%9E%88%EB%8A%94-PHPickerViewController%EB%A5%BC-%EC%95%8C%EC%95%84%EB%B3%B4%EC%9E%90
    }
}



final class MyFrameCell: UITableViewCell {
    static let reuseId = "myframeCell"
    
    @IBOutlet weak var greydot: UIView!
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var barView: UIView!
    
}
