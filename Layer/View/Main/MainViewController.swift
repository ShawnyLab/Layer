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
    
    @IBOutlet weak var floatingButton: UIButton!
    @IBOutlet weak var floatingButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var floatingButtonTrailing: NSLayoutConstraint!
    @IBOutlet weak var floatingButtonBottom: NSLayoutConstraint!
    
    
    @IBOutlet weak var greyLayer: UIButton!
    @IBOutlet weak var blackLayer: UIButton!
    @IBOutlet weak var whiteLayer: UIButton!
    
    @IBOutlet weak var blackWidth: NSLayoutConstraint!
    @IBOutlet weak var greyWidth: NSLayoutConstraint!
    @IBOutlet weak var whiteWidth: NSLayoutConstraint!
    
    @IBOutlet var longPressRecognizer: UILongPressGestureRecognizer!
    
    private var isPressing = false
    private var isAnimating = false
    private var pressTimer: Timer?
    
    
    
    let pageRelay = BehaviorRelay<Int>(value: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        plusButton.isHidden = true
        circleButton.isHidden = true
        hamburgerButton.isHidden = true

        makeUI()
        bind()
        
        floatingButton.layer.cornerRadius = 23
        
        floatingButton.addGrayShadow(color: .black, opacity: 0.25)
        
        blackWidth.rx.constant.onNext(0)
        greyWidth.rx.constant.onNext(0)
        whiteWidth.rx.constant.onNext(0)
        

        
        pageRelay
            .subscribe(onNext: { [unowned self] index in
                if index == 0 {
                    titleLabel.text = "Layer"
                    plusButton.isHidden = false
                    circleButton.isHidden = true
                    hamburgerButton.isHidden = true
                } else if index == 1 {
                    titleLabel.text = "Message"
                    plusButton.isHidden = true
                    circleButton.isHidden = true
                    hamburgerButton.isHidden = true
                } else if index == 2 {
                    titleLabel.text = "Profile"
                    plusButton.isHidden = true
                    circleButton.isHidden = false
                    hamburgerButton.isHidden = false
                }
            })
            .disposed(by: rx.disposeBag)
        
        floatingButton.rx.controlEvent(.allEvents)
            .subscribe(onNext: { [unowned self] event in
                print(event)
            })
            .disposed(by: rx.disposeBag)
        
        plusButton.rx.tap
            .bind { Void in
                let vc = UIStoryboard(name: "Layer", bundle: nil)
                    .instantiateViewController(withIdentifier: SelectFrameViewController.storyId) as! SelectFrameViewController
                self.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: rx.disposeBag)
    }

    private func makeUI() {
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
    
    @IBAction func longPress(_ sender: Any) {
        isPressing = true
        
        print("long press")
                
        if pressTimer == nil {
            pressTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true, block: { [unowned self] timer in
                if isPressing {
                    isPressing = false
                } else {
                    hideLayers()
                }
            })
        }
        

        
        if !isAnimating {
            isAnimating = true
            showLayers()
        }
        
        
    }
    
    private func showLayers() {
        
        self.blackWidth.constant += 81
        self.greyWidth.constant += 162
        self.whiteWidth.constant += 244
        self.floatingButtonWidth.constant = 0
        self.floatingButtonTrailing.constant += 23
        self.floatingButtonBottom.constant -= 23
        self.whiteLayer.addGrayShadow()
        
        UIView.animate(withDuration: 1.0) {
            self.view.layoutIfNeeded()
            self.blackLayer.layer.cornerRadius = self.blackLayer.frame.width/2
            self.greyLayer.layer.cornerRadius = self.greyLayer.frame.width/2
            self.whiteLayer.layer.cornerRadius = self.whiteLayer.frame.width/2
            self.floatingButton.layer.cornerRadius = self.floatingButton.frame.width/2
        } completion: { _ in
            
        }

    }
    
    private func hideLayers() {
        self.blackWidth.constant = 0
        self.greyWidth.constant = 0
        self.whiteWidth.constant = 0
        self.floatingButtonWidth.constant = 46
        self.floatingButtonTrailing.constant = 30
        self.floatingButtonBottom.constant = -30
        
        UIView.animate(withDuration: 1.0) {
            self.view.layoutIfNeeded()
            self.blackLayer.layer.cornerRadius = self.blackLayer.frame.width/2
            self.greyLayer.layer.cornerRadius = self.greyLayer.frame.width/2
            self.whiteLayer.layer.cornerRadius = self.whiteLayer.frame.width/2
            self.floatingButton.layer.cornerRadius = self.floatingButton.frame.width/2
        } completion: { _ in
            self.isAnimating = false
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touch began")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touch Ended")
    }
    
    private func bind() {
        guard let pageVC = self.children.first as? MainPageViewController else { fatalError() }
        pageVC.mainVC = self
    }
}
