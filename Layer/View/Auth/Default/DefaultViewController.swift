//
//  DefaultViewController.swift
//  Layer
//
//  Created by 박진서 on 2022/08/15.
//

import UIKit

final class DefaultViewController: UIViewController {

    static let storyId = "defaultVC"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        



    }
    
    override func viewDidAppear(_ animated: Bool) {
        AuthManager.shared.fetch()
            .subscribe {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainVC") as! MainViewController
                let nav = UINavigationController(rootViewController: vc)
                nav.navigationBar.isHidden = true
                nav.modalPresentationStyle = .fullScreen
                nav.modalTransitionStyle = .crossDissolve
                self.present(nav, animated: true)
            } onError: { err in
                print(err)
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "signinVC") as! SignInViewController
                self.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: rx.disposeBag)
    }
    
    
}
