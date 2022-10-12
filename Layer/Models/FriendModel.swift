//
//  FriendModel.swift
//  Layer
//
//  Created by 박진서 on 2022/08/16.
//

import Firebase
import RxSwift
import RxCocoa
import NSObject_Rx

final class FriendModel: NSObject {
    var uid: String!
    var layer: Int!

    
    init?(data: DataSnapshot) {
        super.init()
        
        guard let value = data.value as? [String: Any] else { return nil }
        if let layer = value["layer"] as? Int {
            self.layer = layer
        } else {
            return nil
        }
        self.uid = data.key
    }
    
    init(userModel: UserModel, layer: Int) {
        super.init()
        self.uid = userModel.uid
        self.layer = layer
    }
}
