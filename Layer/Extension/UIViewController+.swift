//
//  UIViewController+.swift
//  Layer
//
//  Created by 박진서 on 2022/11/25.
//

import UIKit

extension UIViewController {
    func presentAlert(message: String) {
        let alert = UIAlertController(title: "알림", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: { (UIAlertAction) in
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func openUserProfile(userModel: UserModel) {
        let vc = UIStoryboard(name: "Layer", bundle: nil).instantiateViewController(withIdentifier: UserProfileViewController.storyId) as! UserProfileViewController
        vc.userModel = userModel
        if let nav = self.navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
    }
}
