//
//  FrameUploadModel.swift
//  Layer
//
//  Created by 박진서 on 2022/10/05.
//

import FirebaseDatabase

final class FrameUploadModel {
    var title: String!
    var content: String?
    var imageUrl: String?
    var isTemp: Bool = false
    var isOpened: Bool = false
    var layer: Int = 0
}

extension FrameUploadModel {
    //MARK: Todo - Model 화 작업
    private func modelize() -> FrameModel {
        var dueDate: String?
        let date = Date()
        if isTemp {
            dueDate = Date().after(day: 1)
        }
        
        let key = Database.database().reference().child("frame").childByAutoId().key!
        return FrameModel(title: self.title, content: self.content, uid: key, createdAt: date.dateTime, writerId: CurrentUserModel.shared.uid, imageUrl: self.imageUrl, dueDate: dueDate, isOpened: self.isOpened, layer: self.layer)
    }
    
    private func simplize(uid: String, dueDate: String?, createdAt: String) -> SimpleFrameModel {
        return SimpleFrameModel(title: self.title, imageUrl: self.imageUrl, dueDate: dueDate, content: self.content, uid: uid, createdAt: createdAt, isOpened: self.isOpened, layer: self.layer)
    }
    
    private func setValueOnDatabase(ref: DatabaseReference, frameModel: FrameModel) {
        ref.setValue(["title": frameModel.title, "createdAt": frameModel.createdAt, "writerId": frameModel.writerId, "isOpened": frameModel.isOpened, "layer": frameModel.layer])
        if let content = frameModel.content {
            ref.child("content").setValue(content)
        }
        if let imageUrl = frameModel.imageUrl {
            ref.child("imageUrl").setValue(imageUrl)
        }
        if let dueDate = frameModel.dueDate {
            ref.child("dueDate").setValue(dueDate)
        }
    }
    
    func upload() {
        let frameModel = modelize()
        let ref = Database.database(url: "https://layer-8e3e6-default-rtdb.asia-southeast1.firebasedatabase.app").reference().child("frame").child(frameModel.uid)
        
        // Upload in "frame"
        setValueOnDatabase(ref: ref, frameModel: frameModel)
        
        // Add in frameList
        var frameList = FrameManager.shared.frameRelay.value
        frameList.insert(frameModel, at: 0)
        FrameManager.shared.frameRelay.accept(frameList)
        
        // Add in simpleFrames
        let simpleFrameModel = simplize(uid: frameModel.uid, dueDate: frameModel.dueDate, createdAt: frameModel.createdAt)
        CurrentUserModel.shared.frameModels.insert(simpleFrameModel, at: 0)
        
        // Add in users
        let userRef = Database.database(url: "https://layer-8e3e6-default-rtdb.asia-southeast1.firebasedatabase.app")
            .reference()
            .child("users")
            .child(CurrentUserModel.shared.uid)
            .child("frames")
            .child(frameModel.uid)
        setValueOnDatabase(ref: userRef, frameModel: frameModel)

        

    }
}
