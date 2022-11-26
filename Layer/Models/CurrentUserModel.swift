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
    var friendsHash = [String: Int]()
    var frames: [String: Bool] = [:]
    var frameModels: [SimpleFrameModel] = []
    var profileImageUrl: String?
    
    private override init() {
        super.init()
    }

    func setData(data: DataSnapshot) -> Completable {
        return Completable.create() { [unowned self] completable in
            
            guard let value = data.value as? [String: Any] else {
                completable(.error(DataFetchingError.noData))
                return Disposables.create()
            }
            self.uid = data.key
            
            if let layerId = value["layerId"] as? String,
               let phoneNumber = value["phoneNumber"] as? String {
                self.layerId = layerId
                self.phoneNumber = phoneNumber
            } else {
                completable(.error(DataFetchingError.noData))
                return Disposables.create()
            }
            
            self.name = value["name"] as? String
            self.profileImageUrl = value["profileImageUrl"] as? String
            self.des = value["des"] as? String
            
            let friendsData = data.childSnapshot(forPath: "friends")
            
            if friendsData.exists() {
                for friendData in friendsData.children.allObjects as! [DataSnapshot] {
                    if let friendModel = FriendModel(data: friendData) {
                        friends.append(friendModel)
                        friendsHash[friendModel.uid] = friendModel.layer
                    }
                }
            }
            
            let frameData = data.childSnapshot(forPath: "frames")
            
            if frameData.exists() {
                for frames in frameData.children.allObjects as! [DataSnapshot] {
                    if let frameModel = SimpleFrameModel(data: frames) {
                        frameModels.insert(frameModel, at: 0)
                    }
                }
            }
            completable(.completed)
            return Disposables.create()
        }
    }
    
    
    func updateFriends(friends: [FriendModel]) {
        self.friends = friends
        for friend in friends {
            self.friendsHash[friend.uid] = friend.layer
        }
    }

    func uploadImageOnStorage(image: UIImage, completion: @escaping () -> Void) {
        let storageRef = Storage.storage().reference().child("userImages").child(self.uid).child("image.jpeg")
        
        
        let data = image.jpegData(compressionQuality: 0.01)
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
                        
                        self.profileImageUrl = downloadURL.absoluteString
                        UserManager.shared.updateProfileImageUrl(uid: self.uid, url: self.profileImageUrl ?? "")
                        completion()
                    }
                }
            
        }
    }
    
    func updateInfo(name: String?, id: String, des: String?) {
        Database.database(url: "https://layer-8e3e6-default-rtdb.asia-southeast1.firebasedatabase.app").reference().child("users").child(CurrentUserModel.shared.uid).child("name").setValue(name)
        Database.database(url: "https://layer-8e3e6-default-rtdb.asia-southeast1.firebasedatabase.app").reference().child("users").child(CurrentUserModel.shared.uid).child("layerId").setValue(id)
        Database.database(url: "https://layer-8e3e6-default-rtdb.asia-southeast1.firebasedatabase.app").reference().child("users").child(CurrentUserModel.shared.uid).child("des").setValue(des)
        self.name = name
        self.layerId = id
        self.des = des
    }
}
