//
//  MainViewController.swift
//  Layer
//
//  Created by 박진서 on 2022/07/27.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import AVFoundation

class MainViewController: UIViewController {
    static let storyId = "mainVC"
    

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var firstDot: UIView!
    @IBOutlet weak var secondDot: UIView!
    @IBOutlet weak var thirdDot: UIView!
    
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var circleButton: UIButton!
    @IBOutlet weak var hamburgerButton: UIButton!
    
    @IBOutlet weak var floatingButton: FloatingButton!
    @IBOutlet weak var floatingButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var floatingButtonHeight: NSLayoutConstraint!
    
    @IBOutlet weak var floatingButtonTrailing: NSLayoutConstraint!
    @IBOutlet weak var floatingButtonBottom: NSLayoutConstraint!
    
    
    @IBOutlet weak var greyLayer: UIButton!
    @IBOutlet weak var blackLayer: UIButton!
    @IBOutlet weak var whiteLayer: UIButton!
    
    @IBOutlet weak var blackWidth: NSLayoutConstraint!
    @IBOutlet weak var greyWidth: NSLayoutConstraint!
    @IBOutlet weak var whiteWidth: NSLayoutConstraint!
    
    @IBOutlet weak var logoImage: UIImageView!
    
    private var isPressing = false
    private var isAnimating = false
    
    let layerRelay = BehaviorRelay<LayerType>(value: .white)
    
    let pageRelay = BehaviorRelay<Int>(value: 0)
    
    override func viewWillDisappear(_ animated: Bool) {
        isPressing = false
        isAnimating = false
        hideLayers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.floatingButton.mainView = self.view
        
        plusButton.isHidden = true
        circleButton.isHidden = true
        hamburgerButton.isHidden = true

        bind()
        
        self.floatingButton.layer.cornerRadius = 30
        
        floatingButton.addGrayShadow(color: .black, opacity: 0.25)
        
        blackWidth.rx.constant.onNext(0)
        greyWidth.rx.constant.onNext(0)
        whiteWidth.rx.constant.onNext(0)
        

        
        pageRelay
            .subscribe(onNext: { [unowned self] index in
                if index == 0 {
                    titleLabel.isHidden = true
                    logoImage.isHidden = false
                    plusButton.isHidden = false
                    circleButton.isHidden = true
                    hamburgerButton.isHidden = true
                } else if index == 1 {
                    titleLabel.text = "Message"
                    titleLabel.isHidden = false
                    logoImage.isHidden = true
                    plusButton.isHidden = true
                    circleButton.isHidden = true
                    hamburgerButton.isHidden = true
                } else if index == 2 {
                    titleLabel.text = "Profile"
                    titleLabel.isHidden = false
                    logoImage.isHidden = true
                    plusButton.isHidden = true
                    circleButton.isHidden = false
                    hamburgerButton.isHidden = false
                }
            })
            .disposed(by: rx.disposeBag)
        
        plusButton.rx.tap
            .bind { Void in
                let vc = UIStoryboard(name: "Layer", bundle: nil)
                    .instantiateViewController(withIdentifier: SelectFrameViewController.storyId) as! SelectFrameViewController
                self.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: rx.disposeBag)
        
        floatingButton.hideLayer = {
            self.hideLayers()
        }
        
        floatingButton.openLayer = {
            self.showLayers()
        }
        
        floatingButton.changeLayer = { layer in
            self.changeLayer(layer)
        }

        circleButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                let vc = UIStoryboard(name: "Manage", bundle: nil).instantiateViewController(withIdentifier: "layermanageVC") as! LayerManageViewController
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: rx.disposeBag)
        
        layerRelay
            .subscribe(onNext: { [unowned self] layer in
                switch layer {
                case .white:
                    whiteDot()
                    showWhite()
                case .black:
                    blackDot()
                    showBlack()
                case .gray:
                    whiteDot()
                    showGray()
                }
            })
            .disposed(by: rx.disposeBag)
        
        floatingButton.rx.tap
            .bind { [unowned self] _ in
                print("tap")
            }
            .disposed(by: rx.disposeBag)
    }

    private func whiteDot() {
        firstDot.layer.cornerRadius = 3
        firstDot.layer.borderWidth = 1
        firstDot.layer.borderColor = UIColor.black.cgColor
        secondDot.layer.cornerRadius = 3
        secondDot.layer.borderWidth = 1
        secondDot.layer.borderColor = UIColor.black.cgColor
        thirdDot.layer.cornerRadius = 3
        thirdDot.layer.borderWidth = 1
        thirdDot.layer.borderColor = UIColor.black.cgColor
        
        pageRelay.subscribe(onNext: { [unowned self] page in
            if page == 0 {
                firstDot.backgroundColor = .black
                secondDot.backgroundColor = .white
                thirdDot.backgroundColor = .white
            } else if page == 1 {
                firstDot.backgroundColor = .white
                secondDot.backgroundColor = .black
                thirdDot.backgroundColor = .white
            } else if page == 2 {
                firstDot.backgroundColor = .white
                secondDot.backgroundColor = .white
                thirdDot.backgroundColor = .black
            }
        })
        .disposed(by: rx.disposeBag)
    }
    
    private func blackDot() {
        firstDot.layer.cornerRadius = 3
        firstDot.layer.borderWidth = 1
        firstDot.layer.borderColor = UIColor.white.cgColor
        secondDot.layer.cornerRadius = 3
        secondDot.layer.borderWidth = 1
        secondDot.layer.borderColor = UIColor.white.cgColor
        thirdDot.layer.cornerRadius = 3
        thirdDot.layer.borderWidth = 1
        thirdDot.layer.borderColor = UIColor.white.cgColor
        
        pageRelay.subscribe(onNext: { [unowned self] page in
            if page == 0 {
                firstDot.backgroundColor = .white
                secondDot.backgroundColor = .black
                thirdDot.backgroundColor = .black
            } else if page == 1 {
                firstDot.backgroundColor = .black
                secondDot.backgroundColor = .white
                thirdDot.backgroundColor = .black
            } else if page == 2 {
                firstDot.backgroundColor = .black
                secondDot.backgroundColor = .black
                thirdDot.backgroundColor = .white
            }
        })
        .disposed(by: rx.disposeBag)
    }
    
    private func showLayers() {
            
        if !isAnimating {
            self.blackWidth.constant += 96
            self.floatingButtonWidth.constant = 0
            self.floatingButtonHeight.constant = 0
            self.floatingButtonTrailing.constant += 30
            self.floatingButtonBottom.constant -= 30
            self.whiteLayer.addGrayShadow()
            AudioServicesPlaySystemSound(1519)
            
            UIView.animate(withDuration: 0.4, animations: {
                self.view.layoutIfNeeded()
                self.blackLayer.layer.cornerRadius = 48
                self.floatingButton.layer.cornerRadius = self.floatingButton.frame.width/2
            })
            
            animateGrayLayer()
            animateWhiteLayer()
            
        }
        

    }
    
    private func animateGrayLayer() {
        self.greyWidth.constant += 192
        UIView.animate(withDuration: 0.4, delay: 0.2, animations: {
            self.view.layoutIfNeeded()
            self.greyLayer.layer.cornerRadius = 96
        })
    }
    
    private func animateWhiteLayer() {
        self.whiteWidth.constant += 300
        UIView.animate(withDuration: 0.4, delay: 0.4, animations: {
            self.view.layoutIfNeeded()
            self.whiteLayer.layer.cornerRadius = 150
        }) { _ in
            self.isAnimating = true
        }
    }
    
    private func hideLayers() {
        self.whiteWidth.constant = 0
        self.floatingButtonWidth.constant = 60
        self.floatingButtonHeight.constant = 60

        self.floatingButtonTrailing.constant = 30
        self.floatingButtonBottom.constant = -30
        UIView.animate(withDuration: 0.6, animations: {
            self.view.layoutIfNeeded()
            self.whiteLayer.layer.cornerRadius = self.whiteLayer.frame.width/2
            self.floatingButton.layer.cornerRadius = self.floatingButton.frame.width/2

        }) { _ in
            self.isAnimating = false

        }
        
        self.greyWidth.constant = 0
        UIView.animate(withDuration: 0.5, delay: 0.1) {
            self.view.layoutIfNeeded()
            self.greyLayer.layer.cornerRadius = self.greyLayer.frame.width/2
        }
        
        self.blackWidth.constant = 0
        UIView.animate(withDuration: 0.4, delay: 0.2) {
            self.view.layoutIfNeeded()
            self.blackLayer.layer.cornerRadius = self.greyLayer.frame.width/2
        }
    }
    
    private func changeLayer(_ layer: LayerType) {
        switch layer {
        case .black:
            changeToBlackLayer()
        case .gray:
            changeToGrayLayer()
        case .white:
            changeToWhiteLayer()
            break
        }
    }
    
    private func changeToBlackLayer() {
        self.whiteWidth.constant = 0
        self.floatingButtonWidth.constant = 60
        self.floatingButtonHeight.constant = 60
        self.floatingButtonTrailing.constant = 30
        self.floatingButtonBottom.constant = -30
        UIView.animate(withDuration: 0.6, delay: 0.3, animations: {
            self.view.layoutIfNeeded()
            self.whiteLayer.layer.cornerRadius = self.whiteLayer.frame.width/2
            self.floatingButton.layer.cornerRadius = self.floatingButton.frame.width/2
            self.layerRelay.accept(.black)

        }) { _ in
            self.isAnimating = false
        }
        
        self.greyWidth.constant = 0
        UIView.animate(withDuration: 0.5, delay: 0.1) {
            self.view.layoutIfNeeded()
            self.greyLayer.layer.cornerRadius = self.greyLayer.frame.width/2
        }
        
        self.blackWidth.constant = UIScreen.main.bounds.height*2
        
        UIView.animate(withDuration: 0.4, delay: 0.3, animations: {
            self.view.layoutIfNeeded()
            self.blackLayer.alpha = 0
            self.blackLayer.layer.cornerRadius = self.greyLayer.frame.width/2
        }) { _ in
            self.blackWidth.constant = 0
            self.blackLayer.alpha = 1
        }
    }
    
    private func changeToWhiteLayer() {
        self.floatingButtonWidth.constant = 60
        self.floatingButtonHeight.constant = 60
        self.floatingButtonTrailing.constant = 30
        self.floatingButtonBottom.constant = -30
        UIView.animate(withDuration: 0.6, delay: 0.3, animations: {
            self.view.layoutIfNeeded()
            self.floatingButton.layer.cornerRadius = self.floatingButton.frame.width/2
            
        }) { _ in
            self.isAnimating = false
            self.layerRelay.accept(.white)

        }
        self.greyWidth.constant = 0
        UIView.animate(withDuration: 0.5, delay: 0.1) {
            self.view.layoutIfNeeded()
            
            self.greyLayer.layer.cornerRadius = self.greyLayer.frame.width/2
        }
        
        self.blackWidth.constant = 0
        self.whiteWidth.constant = UIScreen.main.bounds.height*2

        UIView.animate(withDuration: 0.4, delay: 0.3, animations: {
            self.view.layoutIfNeeded()
            self.whiteLayer.layer.cornerRadius = self.whiteLayer.frame.width/2
            self.blackLayer.layer.cornerRadius = self.greyLayer.frame.width/2
            
            self.whiteLayer.alpha = 0
        }) { _ in
            self.whiteWidth.constant = 0
            self.whiteLayer.alpha = 1
        }
    }
    
    private func changeToGrayLayer() {
        self.floatingButtonWidth.constant = 60
        self.floatingButtonHeight.constant = 60
        self.floatingButtonTrailing.constant = 30
        self.floatingButtonBottom.constant = -30
        UIView.animate(withDuration: 0.6, delay: 0.3, animations: {
            self.view.layoutIfNeeded()
            self.floatingButton.layer.cornerRadius = self.floatingButton.frame.width/2
            self.layerRelay.accept(.gray)
        }) { _ in
            self.isAnimating = false

        }
        self.greyWidth.constant = 0
        UIView.animate(withDuration: 0.5, delay: 0.1) {
            self.view.layoutIfNeeded()
            
            self.greyLayer.layer.cornerRadius = self.greyLayer.frame.width/2
        }
        
        self.blackWidth.constant = 0
        self.whiteWidth.constant = UIScreen.main.bounds.height*2

        UIView.animate(withDuration: 0.4, delay: 0.3, animations: {
            self.view.layoutIfNeeded()
            self.whiteLayer.layer.cornerRadius = self.whiteLayer.frame.width/2
            self.blackLayer.layer.cornerRadius = self.greyLayer.frame.width/2
            
            self.whiteLayer.alpha = 0
        }) { _ in
            self.whiteWidth.constant = 0
            self.whiteLayer.alpha = 1
        }
    }
    
    private func showBlack() {
        
        UIView.animate(withDuration: 0.4, animations: { [unowned self] in
            view.backgroundColor = .black
            logoImage.image = UIImage(named: "logoWhite")
            plusButton.setImage(UIImage(named: "plusWhite"), for: .normal)
            floatingButton.backgroundColor = .black
            floatingButton.layer.borderWidth = 1
            floatingButton.layer.borderColor = UIColor.white.cgColor
            titleLabel.textColor = .white
            hamburgerButton.setImage(UIImage(named: "hamburgerWhite"), for: .normal)
            circleButton.setImage(UIImage(named: "doubleCircleWhite"), for: .normal)
        })

    }
    
    private func showWhite() {
        view.backgroundColor = .white
        logoImage.image = UIImage(named: "logoBlack")
        plusButton.setImage(UIImage(named: "plusBlack"), for: .normal)
        floatingButton.backgroundColor = .white
        floatingButton.layer.borderWidth = 0
        titleLabel.textColor = .black
        hamburgerButton.setImage(UIImage(named: "hamburgerBlack"), for: .normal)
        circleButton.setImage(UIImage(named: "doubleCircleBlack"), for: .normal)
        
    }
    
    private func showGray() {
        view.backgroundColor = .layerGray
        logoImage.image = UIImage(named: "logoBlack")
        plusButton.setImage(UIImage(named: "plusBlack"), for: .normal)
        floatingButton.backgroundColor = .gray
        floatingButton.layer.borderWidth = 0
        titleLabel.textColor = .black
        hamburgerButton.setImage(UIImage(named: "hamburgerBlack"), for: .normal)
        circleButton.setImage(UIImage(named: "doubleCircleBlack"), for: .normal)

    }
    
    private func bind() {
        guard let pageVC = self.children.first as? MainPageViewController else { fatalError() }
        self.layerRelay
            .bind(to: pageVC.layerRelay)
            .disposed(by: rx.disposeBag)
        pageVC.mainVC = self
    }
    
    @IBAction func setting(_ sender: Any) {
        let vc = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "settingVC") as! SettingViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

final class FloatingButton: UIButton {
    private var pressTimer: Timer?
    private var isPressing = false
    private var cnt = 0
    
    var openLayer: (() -> Void)!
    var hideLayer: (() -> Void)!
    var changeLayer: ((LayerType) -> Void)!
    var mainView: UIView!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if pressTimer == nil {
            pressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { timer in
                self.cnt += 1
                if self.cnt == 2 {
                    self.isPressing = true
                    self.openLayer()
                    timer.invalidate()
                    self.pressTimer = nil
                }
            })
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        cnt = 0
        print("touches ended")
        let location = touches.first!.location(in: self.mainView)
        
        print(self.frame.origin.x, self.frame.origin.y)
        
        
        let xGap = self.frame.origin.x - location.x
        let yGap = self.frame.origin.y - location.y
        
        if xGap*xGap + yGap*yGap <= 49*49 {
            changeLayer(.black)
        } else if xGap*xGap + yGap*yGap <= 98*98 {
            changeLayer(.gray)
        } else if xGap*xGap + yGap*yGap <= 150*150 {
            changeLayer(.white)
        } else {
            hideLayer()
        }
        
        self.pressTimer?.invalidate()
        self.pressTimer = nil
    }

}

enum LayerType: Int {
    case white
    case gray
    case black
}
