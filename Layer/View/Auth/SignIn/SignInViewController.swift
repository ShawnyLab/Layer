//
//  SignInViewController.swift
//  Layer
//
//  Created by 박진서 on 2022/07/27.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import FirebaseAuth


final class SignInViewController: UIViewController {

    @IBOutlet var viewModel: SignInViewModel!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var numberTextfield: UITextField!
    @IBOutlet weak var codeTextfield: UITextField!
    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var helpView: UIView!
    
    var phoneNumber: String!
    var verifId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indicator.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        makeUI()
        bind()
    }
    

    private func makeUI() {
        nextButton.layer.cornerRadius = 13
        bottomView.isHidden = true
        
        
    }

    private func bind() {
        

        numberTextfield.rx.text
            .orEmpty
            .subscribe(onNext: { [unowned self] number in
                if number.count == 11 && Int(number) != nil {
                    nextButton.isEnabled = true
                    nextButton.backgroundColor = .black
                } else {
                    nextButton.isEnabled = false
                    nextButton.backgroundColor = UIColor(red: 108, green: 108, blue: 108)
                }
            })
            .disposed(by: rx.disposeBag)
        
        nextButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                indicator.isHidden = false
                indicator.startAnimating()
                view.endEditing(true)

                if numberTextfield.isHidden == false {
                    self.phoneNumber = numberTextfield.text!
                    Auth.auth().languageCode = "kr"
                    PhoneAuthProvider
                        .provider()
                        .verifyPhoneNumber("+82\(numberTextfield.text!)", uiDelegate: nil) { [unowned self] verificationId, error in
                            titleLabel.text = "\(numberTextfield.text!)로 보낸 인증번호를 입력해주세요."
                            
                            indicator.isHidden = true
                            indicator.stopAnimating()
                            
                            if let verifId = verificationId {
                                print("verifId")
                                numberTextfield.text = nil
                                numberTextfield.isHidden = true
                                codeTextfield.isHidden = false
                                nextButton.isEnabled = false
                                nextButton.backgroundColor = UIColor(red: 108, green: 108, blue: 108)
                                
                                self.verifId = verifId
                            } else {
                                print(error)
                            }
                        }
                    self.helpView.isHidden = true
                } else if codeTextfield.isHidden == false {
                    self.helpView.isHidden = true
                    let credential = PhoneAuthProvider.provider().credential(
                      withVerificationID: verifId,
                      verificationCode: codeTextfield.text!
                    )
                    
                    Auth.auth().signIn(with: credential) { [unowned self] result, error in
                        if result != nil{
                            AuthManager.shared.fetch()
                                .subscribe {
                                    print("auth fetch")
                                    self.navigationController?.popToRootViewController(animated: true)
                                } onError: { [unowned self] err in
                                    print(err)

                                    indicator.stopAnimating()
                                    indicator.isHidden = true
                                    
                                    codeTextfield.text = nil
                                    codeTextfield.isHidden = true
                                    
                                    nextButton.isEnabled = false
                                    nextButton.backgroundColor = UIColor(red: 108, green: 108, blue: 108)
                                    
                                    titleLabel.text = "레이어 계정 아이디는 무엇으로 할까요?"
                                    nameTextfield.isHidden = false
                                    

                                }
                                .disposed(by: rx.disposeBag)
                        }
                    }
                } else if nameTextfield.isHidden == false {
                    self.helpView.isHidden = true
                    indicator.stopAnimating()
                    indicator.isHidden = true
                    AuthManager.shared.createUser(id: nameTextfield.text!, phoneNumber: self.phoneNumber!)
//                    self.navigationController?.popToRootViewController(animated: true)
                    let nav = self.storyboard?.instantiateViewController(withIdentifier: "authfinalVC") as! AuthFinalViewController
                    self.navigationController?.pushViewController(nav, animated: true)
                }

            })
            .disposed(by: rx.disposeBag)
        
        codeTextfield
            .rx
            .text
            .orEmpty
            .subscribe(onNext: { [unowned self] code in
                if code.count == 6 {
                    nextButton.isEnabled = true
                    nextButton.backgroundColor = .black
                } else {
                    nextButton.isEnabled = false
                    nextButton.backgroundColor = UIColor(red: 108, green: 108, blue: 108)
                }
            })
            .disposed(by: rx.disposeBag)
        
        nameTextfield
            .rx
            .text
            .orEmpty
            .subscribe(onNext: { [unowned self] code in
                if code.count >= 3 {
                    nextButton.isEnabled = true
                    nextButton.backgroundColor = .black
                } else {
                    nextButton.isEnabled = false
                    nextButton.backgroundColor = UIColor(red: 108, green: 108, blue: 108)
                }
            })
            .disposed(by: rx.disposeBag)
        
    }
    
    @objc func keyboardWillShowNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        let keyboardHeight = keyboardFrame.height
        
        bottomView.isHidden = false
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.bottomView.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight)
        }
    }
    
    @IBAction func license(_ sender: Any) {
        //https://tom7930.tistory.com/54
        if let url = URL(string: "https://github.com/ShawnyLab/collhumanart") {
            UIApplication.shared.open(url, options: [:])
        }

        
    }
    
    @objc func keyboardWillHideNotification(_ notification: Notification) {
        bottomView.isHidden = true
        bottomView.transform = .identity
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
}
