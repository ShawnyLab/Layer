//
//  YourChatTableViewCell.swift
//  Layer
//
//  Created by 박진서 on 2022/10/13.
//

import UIKit

class YourChatTableViewCell: UITableViewCell {

    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var frameView: UIView!
    @IBOutlet weak var frameImageView: UIImageView!
    @IBOutlet weak var frameContainer: UIView!
    @IBOutlet weak var frameTitleLabel: UILabel!
    @IBOutlet weak var frameContentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        messageView.layer.cornerRadius = 13
        profileImageView.layer.cornerRadius = 10
        frameContainer.layer.borderWidth = 1
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
