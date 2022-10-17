//
//  ChatModel.swift
//  Layer
//
//  Created by 박진서 on 2022/10/13.
//

import FirebaseDatabase

final class ChatModel {
    let message: String
    let userId: String
    let createdAt: String
    let dueDate: String?
    let uid: String
    
    init(message: String, userId: String, createdAt: String, dueDate: String?, uid: String) {
        self.message = message
        self.userId = userId
        self.createdAt = createdAt
        self.dueDate = dueDate
        self.uid = uid
    }
    
    init?(data: DataSnapshot) {
        if data.exists() {
            let value = data.value as! [String: Any]
            
            self.uid = data.key
            
            if let message = value["message"] as? String,
               let userId = value["userId"] as? String,
               let createdAt = value["createdAt"] as? String {
                self.message = message
                self.userId = userId
                self.createdAt = createdAt
            } else {
                return nil
            }
               
            self.dueDate = value["dueDate"] as? String
            
            
            
        } else {
            return nil
        }
    }
}
