//
//  UIButton.swift
//  Layer
//
//  Created by 박진서 on 2022/10/06.
//

import UIKit

class CircleButton: UIButton {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let circlePath = UIBezierPath(ovalIn: self.bounds)
        return circlePath.contains(point)
    }
}
