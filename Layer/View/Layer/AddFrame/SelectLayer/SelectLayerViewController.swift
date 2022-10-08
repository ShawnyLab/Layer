//
//  SelectLayerViewController.swift
//  Layer
//
//  Created by 박진서 on 2022/10/04.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class SelectLayerViewController: AddFrameType {
    static let storyId = "selectlayerVC"
    
    @IBOutlet weak var tempSwitch: UISwitch!
    @IBOutlet weak var profileSwitch: UISwitch!
    
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var tempView: UIView!
    
    
    @IBOutlet weak var profileLabel: UILabel!
    @IBOutlet weak var profileView: UIView!
    
    @IBOutlet weak var whiteView: UIView!
    @IBOutlet weak var grayView: UIView!
    @IBOutlet weak var blackView: UIView!
    
    
    @IBOutlet weak var layerWhiteButton: UIButton!
    @IBOutlet weak var layerGrayButton: UIButton!
    @IBOutlet weak var layerBlackButton: UIButton!
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var uploadButton: UIButton!
    
    private let whiteOn = BehaviorRelay(value: true)
    private let grayOn = BehaviorRelay(value: true)
    private let blackOn = BehaviorRelay(value: true)
    
    private let tempSubject = BehaviorSubject(value: true)
    private let profileSubject = BehaviorSubject(value: true)
    
    private var totalLayer: Int = 7
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicator.isHidden = true
        
        tempView.layer.cornerRadius = 13
        tempView.layer.borderColor = UIColor.black.cgColor
        tempView.layer.borderWidth = 1
        
        profileView.layer.borderWidth = 1
        profileView.layer.borderColor = UIColor.black.cgColor
        profileView.layer.cornerRadius = 13
        


        layerWhiteButton.rx.tap
            .bind { [unowned self] Void in
                print("white")
                if whiteOn.value {
                    whiteOn.accept(false)
                    totalLayer -= 4
                } else {
                    whiteOn.accept(true)
                    totalLayer += 4
                }
            }
            .disposed(by: rx.disposeBag)
        
        layerGrayButton.rx.tap
            .bind { [unowned self] Void in
                print("gray")
                if grayOn.value {
                    grayOn.accept(false)
                    totalLayer -= 2
                } else {
                    grayOn.accept(true)
                    totalLayer += 2
                }
            }
            .disposed(by: rx.disposeBag)
        
        layerBlackButton.rx.tap
            .bind { [unowned self] Void in
                print("black")
                if blackOn.value {
                    blackOn.accept(false)
                    totalLayer -= 1
                } else {
                    blackOn.accept(true)
                    totalLayer += 1
                }
            }
            .disposed(by: rx.disposeBag)
        
        blackOn
            .subscribe(onNext: { [unowned self] isOn in
                if isOn {
                    layerBlackButton.backgroundColor = .black
                    blackView.layer.borderWidth = 0
                } else {
                    layerBlackButton.backgroundColor = .white
                    blackView.layer.borderWidth = 1
                    blackView.layer.borderColor = UIColor.layerGray.cgColor
                }
            })
            .disposed(by: rx.disposeBag)
        
        grayOn
            .subscribe(onNext: { [unowned self] isOn in
                if isOn {
                    layerGrayButton.backgroundColor = .layerGray
                    grayView.layer.borderWidth = 0
                } else {
                    layerGrayButton.backgroundColor = .white
                    grayView.layer.borderWidth = 1
                    grayView.layer.borderColor = UIColor.layerGray.cgColor
                }
            })
            .disposed(by: rx.disposeBag)
        
        whiteOn
            .subscribe { [unowned self] isOn in
                if isOn {
                    layerWhiteButton.addGrayShadow()
                } else {
                    layerWhiteButton.addGrayShadow(color: .lightGray)
                }
            }
            .disposed(by: rx.disposeBag)
        
        tempSubject
            .map { $0 ? UIColor.black : UIColor(red: 217, green: 217, blue: 217)}
            .subscribe(onNext: { [unowned self] color in
                tempView.layer.borderColor = color.cgColor
                tempLabel.textColor = color
            })
            .disposed(by: rx.disposeBag)
        
        profileSubject
            .map { $0 ? UIColor.black : UIColor(red: 217, green: 217, blue: 217)}
            .subscribe(onNext: { [unowned self] color in
                profileView.layer.borderColor = color.cgColor
                profileLabel.textColor = color
            })
            .disposed(by: rx.disposeBag)
        
        uploadButton
            .rx.tap
            .bind { [unowned self] Void in
                indicator.isHidden = false
                indicator.startAnimating()
                
                frameUploadModel.isOpened = profileSwitch.isOn
                frameUploadModel.isTemp = tempSwitch.isOn
                frameUploadModel.layer = totalLayer
                frameUploadModel.upload() { [unowned self] in
                    indicator.isHidden = true
                    navigationController?.popToRootViewController(animated: true)
                }
            }
            .disposed(by: rx.disposeBag)

        Observable.combineLatest(whiteOn, grayOn, blackOn)
            .map { $0 && $1 && $2 }
            .subscribe { [unowned self] allOn in
                profileSwitch.isEnabled = allOn ? true : false
                
                UIView.animate(withDuration: 1) { [unowned self] in
                    if !allOn {
                        profileSubject.onNext(false)
                        profileSwitch.isOn = false
                    } else {
                        profileSubject.onNext(true)
                        profileSwitch.isOn = true
                    }
                }
            }
            .disposed(by: rx.disposeBag)
        
        profileSwitch.rx.isOn
            .bind(to: profileSubject)
            .disposed(by: rx.disposeBag)
        
        tempSwitch.rx.isOn
            .bind(to: tempSubject)
            .disposed(by: rx.disposeBag)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        whiteView.circular()
        grayView.circular()
        blackView.circular()
        
        layerWhiteButton.circular()

        layerWhiteButton.backgroundColor = .white
        layerGrayButton.backgroundColor = .layerGray
        layerBlackButton.backgroundColor = .black
        
        layerWhiteButton.addGrayShadow()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        whiteView.circular()
        grayView.circular()
        blackView.circular()
    }

    @IBAction func popAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
