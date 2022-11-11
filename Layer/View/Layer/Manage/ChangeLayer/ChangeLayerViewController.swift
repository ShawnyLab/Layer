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

final class ChangeLayerViewController: UIViewController {
    static let storyId = "changelayerVC"

    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var whiteView: UIView!
    @IBOutlet weak var grayView: UIView!
    @IBOutlet weak var blackView: UIView!
 
    @IBOutlet weak var blackLeading: NSLayoutConstraint!
    @IBOutlet weak var grayLeading: NSLayoutConstraint!
    @IBOutlet weak var whiteLeading: NSLayoutConstraint!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    var userModel: UserModel!
    
    var defaultImagePoint: CGPoint!
    
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
                    
                    
                    if diff < whiteWidth {
                        //do something
                    } else {
                        senderView.center = self!.defaultImagePoint
                    }
                } else if sender.state == .changed {
                    if diff < blackWidth {
                        self!.blackLeading.constant = 125
                        self!.blackView.circular()
//                        self!.grayLeading.rx.constant.onNext(87)
//                        self!.whiteLeading.rx.constant.onNext(27)
                    } else if diff < grayWidth {
//                        self!.blackLeading.rx.constant.onNext(147)
//                        self!.grayLeading.rx.constant.onNext(70)
//                        self!.whiteLeading.rx.constant.onNext(27)
                    } else if diff < whiteWidth {
//                        self!.blackLeading.rx.constant.onNext(147)
//                        self!.grayLeading.rx.constant.onNext(70)
//                        self!.whiteLeading.rx.constant.onNext(0)
                    }
                }

                
                sender.setTranslation(.zero, in: view) // 움직인 값을 0으로 초기화

            }).disposed(by: rx.disposeBag)
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

