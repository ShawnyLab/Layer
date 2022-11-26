//
//  UITableViewCell+.swift
//  Layer
//
//  Created by 박진서 on 2022/11/26.
//

import UIKit

extension UITableViewCell {
    open override func awakeFromNib() {
        self.selectionStyle = .none
    }
}
