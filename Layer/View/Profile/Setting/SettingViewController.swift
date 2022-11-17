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
    override func viewDidLoad() {
        super.viewDidLoad()

        profileContainer.layer.cornerRadius = 13
        functionContainer.layer.cornerRadius = 13
        settingContainer.layer.cornerRadius = 13
        infoContainer.layer.cornerRadius = 13
        logoutBtn.layer.cornerRadius = 13
        
        idLabel.text = CurrentUserModel.shared.layerId
        nameLabel.text = CurrentUserModel.shared.name
        profileImageView.setImage(url: CurrentUserModel.shared.profileImageUrl)
    }

    @IBAction func logout(_ sender: Any) {
        try! Auth.auth().signOut()
        self.dismiss(animated: true)
    }
}
