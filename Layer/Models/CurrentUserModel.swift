//
//  CurrentUserModel.swift
//  Layer
//
//  Created by 박진서 on 2022/08/15.
//

import Firebase
import RxSwift
import RxCocoa
import NSObject_Rx

final class CurrentUserModel: NSObject {
    static let shared = CurrentUserModel()
    
    var uid: String!
    var layerId: String!
    var name: String?
    var phoneNumber: String!
    var des: String?
    var friends: [FriendModel] = []
    var frames: [String: Bool] = [:]
    var frameModels: [SimpleFrameModel] = []
    var profileImageUrl: String?
    
    private override init() {
        super.init()
    }

    func setData(data: DataSnapshot) {
        guard let value = data.value as? [String: Any] else { return }
        self.uid = data.key
        
        if let layerId = value["layerId"] as? String,
           let phoneNumber = value["phoneNumber"] as? String {
            self.layerId = layerId
            self.phoneNumber = phoneNumber
        } else {
            return
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
        
        let frameData = data.childSnapshot(forPath: "frames")
        
        if frameData.exists() {
            for frames in frameData.children.allObjects as! [DataSnapshot] {
                if let frameModel = SimpleFrameModel(data: frames) {
                    frameModels.append(frameModel)
                }
            }
        }

    }
    
    
    func updateFriends(friends: [FriendModel]) {
        self.friends = friends
    }

}
