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
}
