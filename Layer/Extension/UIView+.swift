//
//  UIView+.swift
//  Layer
//
//  Created by 박진서 on 2022/07/15.
//

import Foundation
import UIKit

extension UIView {
    enum VerticalLocation {
        case bottom
        case top
        case left
        case right
    }

    func addShadow(location: VerticalLocation, color: UIColor =  .gray, opacity: Float = 0.5, radius: CGFloat = 0.7) {
        switch location {
        case .bottom:
             addShadow(offset: CGSize(width: 0, height: 3), color: color, opacity: opacity, radius: radius)
        case .top:
            addShadow(offset: CGSize(width: 0, height: -3), color: color, opacity: opacity, radius: radius)
        case .left:
            addShadow(offset: CGSize(width: -10, height: 0), color: color, opacity: opacity, radius: radius)
        case .right:
            addShadow(offset: CGSize(width: 10, height: 0), color: color, opacity: opacity, radius: radius)
        }
    }
    
    func addGrayShadow(color: UIColor = .gray, opacity: Float = 1, radius: CGFloat = 5) {
        addShadow(offset: CGSize(width: 2, height: 2), color: color, opacity: opacity, radius: radius)
    }

    func addShadow(offset: CGSize, color: UIColor = .black, opacity: Float = 0.35, radius: CGFloat = 3.0) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = offset
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    
    func labelViewRoundCorner() {
        self.layer.cornerRadius = self.frame.width / 36.0
    }
    
    func circular() {
        self.layer.cornerRadius = self.bounds.width/2
    }
    
}
