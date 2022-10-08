//
//  AddTextFrameViewController.swift
//  Layer
//
//  Created by 박진서 on 2022/10/04.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class AddTextFrameViewController: AddFrameType {
    static let storyId = "addtextframeVC"

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var titleCountLabel: UILabel!
    @IBOutlet weak var messageCountLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    private let titleCountValidSubject = BehaviorSubject<Bool>(value: true)
    private let messageCountValidSubject = BehaviorSubject<Bool>(value: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton.rx.tap
            .bind { Void in
                self.navigationController?.popViewController(animated: true)
            }
            .disposed(by: rx.disposeBag)
        
        messageTextView.rx.setDelegate(self)
            .disposed(by: rx.disposeBag)
        
        titleTextField.rx.text.orEmpty
            .map { "\($0.count)/25" }
            .bind(to: titleCountLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        titleTextField.rx.text.orEmpty
            .map { $0.count <= 25 && $0.count > 0 }
            .bind(to: titleCountValidSubject)
            .disposed(by: rx.disposeBag)
        
        titleCountValidSubject
            .subscribe { valid in
                self.titleCountLabel.textColor = valid ? UIColor.layerGray : UIColor.red
            }
            .disposed(by: rx.disposeBag)
        
        messageTextView.rx.text.orEmpty
            .map { "\($0.count)/300" }
            .bind(to: messageCountLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        messageTextView.rx.text.orEmpty
            .map { $0.count <= 300 && $0.count > 0 }
            .bind(to: messageCountValidSubject)
            .disposed(by: rx.disposeBag)
        
        messageCountValidSubject
            .subscribe { valid in
                self.messageCountLabel.textColor = valid ? UIColor.layerGray : UIColor.red
            }
            .disposed(by: rx.disposeBag)
        messageTextView.text =  "프레임 메세지는 글자 수 제한이 300자 입니다."
        messageTextView.textColor = UIColor.lightGray
        
        Observable.combineLatest(titleCountValidSubject, messageCountValidSubject)
            .map { $0 && $1 }
            .bind(to: nextButton.rx.isEnabled)
            .disposed(by: rx.disposeBag)
        
        nextButton.rx.tap
            .bind { [unowned self] Void in
                frameUploadModel.title = titleTextField.text!
                frameUploadModel.content = messageTextView.text!                
                
                let vc = storyboard?.instantiateViewController(withIdentifier: "selectlayerVC") as! SelectLayerViewController
                vc.frameUploadModel = frameUploadModel
                self.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: rx.disposeBag)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}

extension AddTextFrameViewController: UITextViewDelegate {
    
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if messageTextView.text.isEmpty {
            messageTextView.text =  "프레임 메세지는 글자 수 제한이 300자 입니다."
            messageTextView.textColor = UIColor.lightGray
        }

    }

    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if messageTextView.textColor == UIColor.lightGray {
            messageTextView.text = nil
            messageTextView.textColor = UIColor.black
        }
    }


}
