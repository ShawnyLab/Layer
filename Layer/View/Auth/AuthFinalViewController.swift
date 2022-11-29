//
//  AuthFinalViewController.swift
//  Layer
//
//  Created by 박진서 on 2022/11/26.
//

import UIKit

final class AuthFinalViewController: UIViewController {
    static let storyId = "authfinalVC"

    @IBOutlet weak var desLabel: UILabel!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        containerView.isHidden = true
        nextBtn.layer.cornerRadius = 13
        mainLabel.text = "\(CurrentUserModel.shared.layerId!)님 만의 자유에요."
        
        let vc = UIStoryboard(name: "Manage", bundle: nil).instantiateViewController(withIdentifier: "addressVC") as! AddressViewController
        
        self.addChild(vc)
        
        self.containerView.addSubview(vc.view)
        vc.view.frame = self.containerView.bounds
        vc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        vc.didMove(toParent: self)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func next(_ sender: Any) {
        UIView.animate(withDuration: 1.0, animations: { [unowned self] in
            desLabel.text = "이제 소중한 친구들을 찾아보아요."
            containerView.isHidden = false
            nextBtn.isHidden = true
        })

    }
    @IBAction func done(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
}
