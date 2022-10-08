//
//  SimpleFrameModel.swift
//  Layer
//
//  Created by 박진서 on 2022/09/20.
//

import Firebase

final class SimpleFrameModel {
    let title: String
    let imageUrl: String?
    let dueDate: String?
    let content: String?
    var uid: String
    let createdAt: String
    var isOpened: Bool = false
    var layer: Int = 0
    
    init(title: String, imageUrl: String?, dueDate: String?, content: String?, uid: String, createdAt: String, isOpened: Bool, layer: Int) {
        self.title = title
        self.imageUrl = imageUrl
        self.dueDate = dueDate
        self.content = content
        self.uid = uid
        self.createdAt = createdAt
        self.isOpened = isOpened
        self.layer = layer
    }
    
    init?(data: DataSnapshot) {
        guard let value = data.value as? [String: Any] else {
            return nil
        }
        self.uid = data.key
        
        if let title = value["title"] as? String,
           let createdAt = value["title"] as? String,
           let isOpened = value["isOpened"] as? Bool,
           let layer = value["layer"] as? Int {
            self.title = title
            self.createdAt = createdAt
            self.isOpened = isOpened
            self.layer = layer
        } else {
            return nil
        }
        
        self.imageUrl = value["imageUrl"] as? String
        self.dueDate = value["dueDate"] as? String
        self.content = value["content"] as? String
        
    }
}
