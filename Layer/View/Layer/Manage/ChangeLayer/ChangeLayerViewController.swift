//
//  ChangeLayerViewController.swift
//  Layer
//
//  Created by 박진서 on 2022/11/11.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import AVFoundation

final class ChangeLayerViewController: UIViewController {
    static let storyId = "changelayerVC"

    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var whiteView: UIView!
    @IBOutlet weak var grayView: UIView!
    @IBOutlet weak var blackView: UIView!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var layerLabel: UILabel!
    
    var userModel: UserModel!
    
    var defaultImagePoint: CGPoint!
    var reload: (() -> Void)!
    
    private let layerStatus = BehaviorRelay<LayerType?>(value: nil)
    private let toShowRelay = BehaviorRelay<[FriendModel]>(value: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()

        whiteView.circular()
        grayView.circular()
        blackView.circular()
        
        whiteView.layer.applySketchShadow(color: .black, alpha: 0.25, x: 0, y: 0, blur: 10, spread: 0)
        grayView.layer.applySketchShadow(color: .black, alpha: 0.25, x: 0, y: 0, blur: 10, spread: 0)
        blackView.layer.applySketchShadow(color: .black, alpha: 0.25, x: 0, y: 0, blur: 10, spread: 0)
        
        profileImageView.circular()
        
        idLabel.text = userModel.layerId
        profileImageView.setImage(url: userModel.profileImageUrl)
        
        setupInputBinding()
        
        collectionView.rx.setDelegate(self)
            .disposed(by: rx.disposeBag)
        collectionView.isHidden = true
        layerLabel.isHidden = true


        layerStatus
            .subscribe(onNext: { [unowned self] type in
                guard let type else { return }
                
                switch type {
                case .white:
                    var temp = [FriendModel]()
                    for friend in CurrentUserModel.shared.friends.filter({$0.layer == 0}) {
                        if temp.count < 7 {
                            temp.append(friend)
                        } else {
                            break
                        }
                    }
                    toShowRelay.accept(temp)
                    break
                case .gray:
                    var temp = [FriendModel]()
                    for friend in CurrentUserModel.shared.friends.filter({$0.layer == 1}) {
                        if temp.count < 7 {
                            temp.append(friend)
                        } else {
                            break
                        }
                    }
                    toShowRelay.accept(temp)
                    break
                case .black:
                    var temp = [FriendModel]()
                    for friend in CurrentUserModel.shared.friends.filter({$0.layer == 2}) {
                        if temp.count < 7 {
                            temp.append(friend)
                        } else {
                            break
                        }
                    }
                    toShowRelay.accept(temp)
                    break
                }
            })
            .disposed(by: rx.disposeBag)
    }
    
    //source : https://ios-development.tistory.com/305
    
    private func setupInputBinding() {
        defaultImagePoint = profileImageView.center
        
        let panGesture = UIPanGestureRecognizer()
        profileImageView.addGestureRecognizer(panGesture)
        panGesture.rx.event.asDriver { _ in .never() }
            .drive(onNext: { [weak self] sender in
                guard let view = self?.view,
                      let senderView = sender.view else {
                    return
                }

                // view에서 움직인 정보
                let transition = sender.translation(in: view)
                senderView.center = CGPoint(x: senderView.center.x + transition.x, y: senderView.center.y + transition.y)

                let cx = senderView.center.x
                let cy = senderView.center.y
                
                let bx = self!.blackView.center.x
                let by = self!.blackView.center.y
                
                let gapX = cx - bx
                let gapY = cy - by
                
                let diff = gapX*gapX + gapY*gapY
                
                let whiteWidth = self!.whiteView.frame.width/2 * self!.whiteView.frame.width/2
                
                let grayWidth = self!.grayView.frame.width/2 * self!.grayView.frame.width/2
                
                let blackWidth = self!.blackView.frame.width/2 * self!.blackView.frame.width/2
                
                if sender.state == .ended {
                    UIView.animate(withDuration: 0.1, animations: {

                        self!.blackView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                        self!.grayView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                        self!.whiteView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                        
                        let vc = self!.storyboard?.instantiateViewController(withIdentifier: "changefinalVC") as! ChangeFinalViewController
                        vc.topVC = self
                        
                        if diff < blackWidth {
                            //do something
                            vc.userModel = self!.userModel
                            vc.layerStatus = .black
                            self!.present(vc, animated: true)

                        } else if diff < grayWidth {
                            vc.userModel = self!.userModel
                            vc.layerStatus = .gray
                            self!.present(vc, animated: true)

                        } else if diff < whiteWidth {
                            vc.userModel = self!.userModel
                            vc.layerStatus = .white
                            
                            self!.present(vc, animated: true)


                        } else {
                            senderView.center = self!.defaultImagePoint
                        }

                    })

                    
                } else if sender.state == .changed {
                    if diff < blackWidth {
                        if self!.layerStatus.value != .black {
                            AudioServicesPlaySystemSound(1519)
                            self!.layerStatus.accept(.black)
                        }
                        
                        UIView.animate(withDuration: 0.1, animations: {

                            self!.blackView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                            self!.grayView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                            self!.whiteView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                            self!.collectionView.isHidden = false
//                            self!.layerLabel.isHidden = false
                        })

                    } else if diff < grayWidth {
                        if self!.layerStatus.value != .gray {
                            AudioServicesPlaySystemSound(1519)
                            self!.layerStatus.accept(.gray)

                        }
                        
                        UIView.animate(withDuration: 0.1, animations: {

                            self!.blackView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                            self!.grayView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                            self!.whiteView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                            self!.collectionView.isHidden = false
                            self!.layerLabel.isHidden = false

                        })
                    } else if diff < whiteWidth {
                        if self!.layerStatus.value != .white {
                            AudioServicesPlaySystemSound(1519)
                            self!.layerStatus.accept(.white)
                        }
                        
                        UIView.animate(withDuration: 0.1, animations: {

                            self!.whiteView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                            self!.grayView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                            self!.blackView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                            self!.collectionView.isHidden = false
                            self!.layerLabel.isHidden = false

                        })
                    } else {
                        self!.layerStatus.accept(nil)

                        
                        UIView.animate(withDuration: 0.1, animations: {

                            self!.whiteView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                            self!.grayView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                            self!.blackView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                            self!.collectionView.isHidden = true
                            self!.layerLabel.isHidden = true

                        })
                    }
                }

                
                sender.setTranslation(.zero, in: view) // 움직인 값을 0으로 초기화

            }).disposed(by: rx.disposeBag)
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

extension ChangeLayerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print(collectionView.frame.width/2-10)
        return CGSize(width: collectionView.frame.width/2-10, height: 50)
    }
}

final class LayerFriendCell: UICollectionViewCell {
    static let reuseId = "layerfriendCell"
    
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    override func awakeFromNib() {
        profileImageView.circular()
    }
}
