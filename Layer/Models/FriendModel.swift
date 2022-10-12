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
    var name: String?
    var layerId: String!
    var layer: Int!
    var profileImageUrl: String?

    
    init?(data: DataSnapshot) {
        super.init()
        
        guard let value = data.value as? [String: Any] else { return nil }
        if let layerId = value["layerId"] as? String,
            let layer = value["layer"] as? Int {
            self.layerId = layerId
            self.layer = layer
        } else {
            return nil
        }
        self.name = value["name"] as? String
        self.uid = data.key
        self.profileImageUrl = value["profileImageUrl"] as? String
    }
    
    init(userModel: UserModel, layer: Int) {
        super.init()
        self.layerId = userModel.layerId
        self.uid = userModel.uid
        self.name = userModel.name
        self.layer = layer
        self.profileImageUrl = userModel.profileImageUrl
    }
}
