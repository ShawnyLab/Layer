//
//  LayerManageViewController.swift
//  Layer
//
//  Created by 박진서 on 2022/10/12.
//

import UIKit

class LayerManageViewController: UIViewController {

    @IBOutlet weak var inviteView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        inviteView.layer.cornerRadius = 13
        inviteView.layer.borderWidth = 1
        inviteView.layer.borderColor = UIColor(red: 153, green: 153, blue: 153).cgColor
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
