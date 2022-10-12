//
//  RequestViewController.swift
//  Layer
//
//  Created by 박진서 on 2022/10/12.
//

import UIKit

class RequestViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    

}

final class RequestCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var denyButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    
    override func awakeFromNib() {
        denyButton.layer.cornerRadius = 13
        denyButton.layer.borderColor = UIColor.black.cgColor
        denyButton.layer.borderWidth = 1
        
        acceptButton.layer.cornerRadius = 13
    }
    
}
