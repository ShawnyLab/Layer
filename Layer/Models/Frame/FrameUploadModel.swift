//
//  FrameUploadModel.swift
//  Layer
//
//  Created by 박진서 on 2022/10/05.
//

import FirebaseDatabase
import FirebaseStorage

final class FrameUploadModel {
    var title: String!
    var content: String?
    var imageUrl: String?
    var isTemp: Bool = false
    var isOpened: Bool = false
    var layer: Int = 0
    var image: UIImage? = nil
}

extension FrameUploadModel {
    //MARK: Todo - Model 화 작업
    private func modelize() -> FrameModel {
        var dueDate: String?
        let date = Date()
        if isTemp {
            dueDate = Date().after(day: 1)
        }
        
        let key = Database.database().reference(fromURL: "https://layer-8e3e6-default-rtdb.asia-southeast1.firebasedatabase.app").child("frame").childByAutoId().key!
        return FrameModel(title: self.title, content: self.content, uid: key, createdAt: date.dateTime, writerId: CurrentUserModel.shared.uid, imageUrl: self.imageUrl, dueDate: dueDate, isOpened: self.isOpened, layer: self.layer)
    }
    
    private func simplize(uid: String, dueDate: String?, createdAt: String) -> SimpleFrameModel {
        return SimpleFrameModel(title: self.title, imageUrl: self.imageUrl, dueDate: dueDate, content: self.content, uid: uid, createdAt: createdAt, isOpened: self.isOpened, layer: self.layer)
    }
    
    private func addTextFrameOnDatabase(ref: DatabaseReference, frameModel: FrameModel, completion: @escaping () -> Void) {
        ref.setValue(["title": frameModel.title, "createdAt": frameModel.createdAt, "writerId": frameModel.writerId, "isOpened": frameModel.isOpened, "layer": frameModel.layer])
        if let content = frameModel.content {
            ref.child("content").setValue(content)
        }
        if let dueDate = frameModel.dueDate {
            ref.child("dueDate").setValue(dueDate)
        }
        
        completion()
    }
    
    private func uploadImageOnStorage(uid: String, completion: @escaping () -> Void) {
        let storageRef = Storage.storage().reference().child("frameImages").child(uid).child("image.jpeg")
        let data = image!.jpegData(compressionQuality: 0.01)
        if let data = data {
            storageRef
                .putData(data) { metadata, error in
                    guard let metadata = metadata else {
                        // Uh-oh, an error occurred!
                        print(error)
                        return
                    }
                    // Metadata contains file metadata such as size, content-type.
                    let size = metadata.size
                    // You can also access to download URL after upload.
                    storageRef.downloadURL { (url, error) in
                        guard let downloadURL = url else {
                            // Uh-oh, an error occurred!
                            print(error)
                            return
                        }
                        
                        self.imageUrl = downloadURL.absoluteString
                        completion()
                    }
                }
            
        }
    }
    
    private func addImageFrameOnDatabase(ref: DatabaseReference, frameModel: FrameModel, completion: @escaping () -> Void) {
        uploadImageOnStorage(uid: frameModel.uid) { [unowned self] in
            ref.setValue(["title": frameModel.title, "createdAt": frameModel.createdAt, "writerId": frameModel.writerId, "isOpened": frameModel.isOpened, "layer": frameModel.layer])
            
            if let dueDate = frameModel.dueDate {
                ref.child("dueDate").setValue(dueDate)
            }
            
            if let imageUrl = imageUrl {
                ref.child("imageUrl").setValue(imageUrl)
            }
            
            completion()
        }
    }
    
    func upload(completion: @escaping () -> Void) {
        let frameModel = modelize()
        let ref = Database.database(url: "https://layer-8e3e6-default-rtdb.asia-southeast1.firebasedatabase.app").reference().child("frame").child(frameModel.uid)
        
        // Upload in "frame"
        if image == nil {
            addTextFrameOnDatabase(ref: ref, frameModel: frameModel) {
                self.addModel(frameModel) {
                    completion()
                }
            }
        } else {
            addImageFrameOnDatabase(ref: ref, frameModel: frameModel) {
                self.addModel(frameModel) {
                    completion()
                }
            }
        }
        
        CurrentUserModel.shared.frames[frameModel.uid] = true
        CurrentUserModel.shared.frameModels.append(SimpleFrameModel(title: frameModel.title, imageUrl: frameModel.imageUrl, dueDate: frameModel.dueDate, content: frameModel.content, uid: frameModel.uid, createdAt: frameModel.createdAt, isOpened: frameModel.isOpened, layer: frameModel.layer))


    }
    
    private func addModel(_ frameModel: FrameModel, completion: @escaping() -> Void) {
        var frameModel = frameModel
        
        // Add in frameList
        if imageUrl != nil {
            frameModel.setImageUrl(imageUrl: self.imageUrl!)
        }
        
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
        
        if image == nil {
            addTextFrameOnDatabase(ref: userRef, frameModel: frameModel) {
                print("text Frame upload done")
                completion()
            }
        } else {
            addImageFrameOnDatabase(ref: userRef, frameModel: frameModel) {
                print("image Frame upload done")
                completion()
            }
        }
        

    }
}
