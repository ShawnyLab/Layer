//
//  SettingViewController.swift
//  Layer
//
//  Created by 박진서 on 2022/11/17.
//

import UIKit
import Firebase

final class SettingViewController: UIViewController {
    static let storyId = "settingVC"
    @IBOutlet weak var profileContainer: UIView!
    @IBOutlet weak var functionContainer: UIView!
    @IBOutlet weak var settingContainer: UIView!
    @IBOutlet weak var infoContainer: UIView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var logoutBtn: UIButton!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var profileEditButton: UIButton!
    @IBOutlet weak var manageButton: UIButton!
    
    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        idLabel.text = CurrentUserModel.shared.layerId
        nameLabel.text = CurrentUserModel.shared.name
        profileImageView.setImage(url: CurrentUserModel.shared.profileImageUrl)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        profileContainer.layer.cornerRadius = 13
        functionContainer.layer.cornerRadius = 13
        settingContainer.layer.cornerRadius = 13
        infoContainer.layer.cornerRadius = 13
        logoutBtn.layer.cornerRadius = 13
        

        profileImageView.circular()
        
        profileEditButton.rx.tap
            .bind { _ in
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "profileeditVC") as! ProfileEditViewController
                self.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: rx.disposeBag)
        
        //https://sulkunblog.tistory.com/49
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
           let bundleVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
        self.versionLabel.text = version
    }
    
    @IBAction func openSetting(_ sender: Any) {
        //https://eeyatho.tistory.com/17
        
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }

        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func manage(_ sender: Any) {
        let vc = UIStoryboard(name: "Manage", bundle: nil).instantiateViewController(withIdentifier: "mylayerVC") as! MyLayerViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func logout(_ sender: Any) {
        try! Auth.auth().signOut()
        self.dismiss(animated: true)
    }
}
