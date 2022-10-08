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
    var name: String!
    var phoneNumber: String!
    var profileImageUrl: String?
    var des: String?
    var friends: [FriendModel] = []
    var frames: [String: Bool] = [:]
    
    init?(data: DataSnapshot) {
        super.init()
        guard let value = data.value as? [String: Any] else { return }
        self.uid = data.key
        
        if let name = value["name"] as? String,
           let phoneNumber = value["phoneNumber"] as? String {
            self.name = name
            self.phoneNumber = phoneNumber
        } else {
            return nil
        }
        
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
        
        let frameData = data.childSnapshot(forPath: "frames")
        
        if frameData.exists() {
            guard let frameValue = frameData.value as? [String: Bool] else { return }
            self.frames = frameValue
        }
        
    }
    
}
