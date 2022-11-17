//
//  UserModel.swift
//  Layer
//
//  Created by 박진서 on 2022/09/20.
//

import Firebase
import RxSwift
import RxCocoa
import NSObject_Rx

final class UserModel: NSObject {
    var uid: String!
    var name: String?
    var layerId: String!
    var phoneNumber: String!
    var profileImageUrl: String?
    var des: String?
    var friends: [FriendModel] = []
    var frameArray: [FrameModel] = []
//    var frames: [String: Bool] = [:]
    
    init?(data: DataSnapshot) {
        super.init()
        guard let value = data.value as? [String: Any] else { return }
        self.uid = data.key
        
        if let phoneNumber = value["phoneNumber"] as? String,
           let layerId = value["layerId"] as? String {
            self.layerId = layerId
            self.phoneNumber = phoneNumber
        } else {
            return nil
        }
        
        self.name = value["name"] as? String
        self.profileImageUrl = value["profileImageUrl"] as? String
        self.des = value["des"] as? String
        let friendsData = data.childSnapshot(forPath: "friends")
        
        if friendsData.exists() {
            for friendData in friendsData.children.allObjects as! [DataSnapshot] {
                if let friendModel = FriendModel(data: friendData) {
                    friends.append(friendModel)
                }
            }
        }
        
        let framesData = data.childSnapshot(forPath: "frames")
        
        if framesData.exists() {
            for frameData in framesData.children.allObjects as! [DataSnapshot] {
                if let frameModel = FrameModel(snapshot: frameData) {
                    frameArray.append(frameModel)
                }
            }
        }
        
    }
    
}
