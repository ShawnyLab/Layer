//
//  UIImageView+.swift
//  Layer
//
//  Created by 박진서 on 2022/07/30.
//

import UIKit
import Kingfisher

extension UIImageView {
    func setImage(url: String?) {
        guard let url = url else {
            self.image = nil
            return
        }
        guard let url = try? URL(string: url) else {
            self.image = nil
            return
        }
        
        self.kf.indicatorType = .activity
        self.kf.setImage(with: url, options: [.transition(.fade(0.3)), .forceTransition, .keepCurrentImageWhileLoading])
    }
    
    func setImage(url: URL) {
        self.kf.indicatorType = .activity
        self.kf.setImage(with: url, options: [.transition(.fade(0.3)), .forceTransition, .keepCurrentImageWhileLoading])
    }
}
