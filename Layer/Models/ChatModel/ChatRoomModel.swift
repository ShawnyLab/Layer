//
//  ChatRoomModel.swift
//  Layer
//
//  Created by 박진서 on 2022/10/20.
//

import Firebase

final class ChatRoomModel: Equatable {
    
    var lastMessage: ChatModel?
    let uid: String
    
    static func == (lhs: ChatRoomModel, rhs: ChatRoomModel) -> Bool {
        return lhs.uid == rhs.uid
    }
    
    init(lastMessage: ChatModel? = nil, uid: String) {
        self.lastMessage = lastMessage
        self.uid = uid
    }
    
    func userIds() -> (String, String) {
        let uidArray = Array(uid).map { String($0) }
        
        var user1 = ""
        var user2 = ""
        var temp = [String]()
        for i in 0..<uid.count {
            if i < uid.count/2 {
                temp.append(uidArray[i])
            } else {
                if i == uid.count/2 {
                    user1 = temp.joined()
                    temp.removeAll()
                }
                temp.append(uidArray[i])
            }
        }
        user2 = temp.joined()
        return (user1, user2)
    }
    
    func otherUserId() -> String {
        var otherUserId: String!
        if self.userIds().1 == CurrentUserModel.shared.uid {
            otherUserId = self.userIds().0
        } else {
            otherUserId = self.userIds().1
        }
        
        return otherUserId
    }
}
