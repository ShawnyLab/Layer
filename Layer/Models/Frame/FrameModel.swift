//
//  FrameModel.swift
//  Layer
//
//  Created by 박진서 on 2022/07/30.
//

import FirebaseDatabase

struct FrameModel: Codable, Equatable {
    let title: String
    var imageUrl: String?
    let dueDate: String?
    let content: String?
    var uid: String
    let createdAt: String
    let writerId: String
    var isOpened: Bool
    var layer: Int
    
    static func ==(lhs: FrameModel, rhs: FrameModel) -> Bool {
        return lhs.uid == rhs.uid
    }
    
    private enum CodingKeys: String, CodingKey {
        case imageUrl, dueDate, content, uid, createdAt, title, writerId, isOpened, layer
    }
    
    init(title: String, content: String?, uid: String, createdAt: String, writerId: String, imageUrl: String?, dueDate: String?, isOpened: Bool, layer: Int) {
        self.title = title
        self.content = content
        self.uid = uid
        self.createdAt = createdAt
        self.imageUrl = imageUrl
        self.dueDate = dueDate
        self.writerId = writerId
        self.isOpened = isOpened
        self.layer = layer
    }
    
    init?(snapshot: DataSnapshot) {
        let data = snapshot.value as! [String: Any]
        guard let title = data["title"] as? String,
              let createdAt = data["createdAt"] as? String,
              let writerId = data["writerId"] as? String,
              let isOpened = data["isOpened"] as? Bool,
              let layer = data["layer"] as? Int
        else {
            print("some error")
            return nil
        }
        
        self.content = data["content"] as? String
        self.title = title
        self.uid = snapshot.key
        self.createdAt = createdAt
        self.writerId = writerId
        self.isOpened = isOpened
        self.layer = layer
        
        self.imageUrl = data["imageUrl"] as? String
        if let dueDate = data["dueDate"] as? String {
            self.dueDate = dueDate
        } else {
            self.dueDate = nil
        }
        
    }
    
    mutating func setImageUrl(imageUrl: String) {
        self.imageUrl = imageUrl
    }
    
    func toUploadModel() -> FrameUploadModel {
        let model = FrameUploadModel()
        model.layer = self.layer
        model.title = self.title
        model.content = self.content
        model.imageUrl = self.imageUrl
        model.isTemp = self.dueDate != nil
        model.isOpened = self.isOpened
        
        return model
    }
}
