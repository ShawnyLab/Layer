//
//  UserManager.swift
//  Layer
//
//  Created by 박진서 on 2022/09/20.
//

import RxSwift
import RxCocoa
import NSObject_Rx

class UserManager: CommonBackendType {
    static let shared = UserManager()
    
    private override init() {}
    
    func fetch(id: String) -> Single<UserModel> {
        return Single.create() { [unowned self] single in
            
            ref.child("users").child(id).observeSingleEvent(of: .value) { DataSnapshot in
                if !DataSnapshot.exists() {
                    single(.error(DataFetchingError.noData))
                } else {
                    if let userModel = UserModel(data: DataSnapshot) {
                        single(.success(userModel))
                    } else {
                        single(.error(DataFetchingError.noData))
                    }
                }
            }
            return Disposables.create()
        }
    }
    
    func sendFriendRequest(userModel: UserModel) {
        ref.child("users").child(CurrentUserModel.shared.uid).child("friends").child(userModel.uid).setValue(["layer": -1])
        
        ref.child("users").child(userModel.uid).child("friends").child(CurrentUserModel.shared.uid).setValue(["layer": -2])
        
        let friendModel = FriendModel(userModel: userModel, layer: -1)
        CurrentUserModel.shared.friends.append(friendModel)
    }
    
    func checkNumber(number: String) -> Single<String?> {
        return Single.create() { [unowned self] single in
            ref.child("numbers").child(number)
                .observeSingleEvent(of: .value) { snapshot in
                    if let value = snapshot.value as? String {
                        single(.success(value))
                    } else {
                        single(.success(nil))
                    }
                }
            
            return Disposables.create()
        }

    }
    
    func cancelFriendRequest(uid: String) {
        if let idx = CurrentUserModel.shared.friends.firstIndex(where: {$0.uid == uid }) {
            CurrentUserModel.shared.friends.remove(at: idx)
        }
        
        ref.child("users").child(CurrentUserModel.shared.uid).child("friends").child(uid).removeValue()
        ref.child("users").child(uid).child("friends").child(CurrentUserModel.shared.uid).removeValue()
        
    }
    
    // set new friend layer to default zero
    func acceptFriendRequest(uid: String) {
        if let idx = CurrentUserModel.shared.friends.firstIndex(where: {$0.uid == uid }) {
            CurrentUserModel.shared.friends[idx].layer = 0
        }
        
        ref.child("users").child(CurrentUserModel.shared.uid).child("friends").child(uid).child("layer").setValue(0)
        ref.child("users").child(uid).child("friends").child(CurrentUserModel.shared.uid).child("layer").setValue(0)
    }
    
    func updateProfileImageUrl(uid: String, url: String) {
        ref.child("users").child(uid).child("profileImageUrl").setValue(url)
    }
    
    func changeLayer(userModel: UserModel, layer: LayerType) {
        guard let preLayer = CurrentUserModel.shared.friendsHash[userModel.uid] else { return } // 기존 레이어
        
        guard let otherUserMe = userModel.friends.first(where: {$0.uid == CurrentUserModel.shared.uid}) else { return }
        guard let otherLayer = otherUserMe.layer else { return } //다른 사람의 레이어
        
        switch layer {
            
        case .black:
            ref.child("users").child(CurrentUserModel.shared.uid).child("friends").child(userModel.uid).child("layer").setValue(20 + preLayer%10)
            ref.child("users").child(userModel.uid).child("friends").child(CurrentUserModel.shared.uid).child("layer").setValue(otherLayer/10 * 10 + 2)
            
        case .gray:
            
            ref.child("users").child(CurrentUserModel.shared.uid).child("friends").child(userModel.uid).child("layer").setValue(10 + preLayer%10)
            ref.child("users").child(userModel.uid).child("friends").child(CurrentUserModel.shared.uid).child("layer").setValue(otherLayer/10 * 10 + 1)

        case .white:
            ref.child("users").child(CurrentUserModel.shared.uid).child("friends").child(userModel.uid).child("layer").setValue(preLayer%10)
            ref.child("users").child(userModel.uid).child("friends").child(CurrentUserModel.shared.uid).child("layer").setValue(otherLayer/10 * 10)

        }
        
        otherUserMe.layer = otherLayer/10 * 10 + layer.rawValue
        CurrentUserModel.shared.friends.first(where: {$0.uid == userModel.uid})!.layer = preLayer%10 + layer.rawValue*10
        CurrentUserModel.shared.friendsHash[userModel.uid] = preLayer%10 + layer.rawValue*10
    }

    func deleteUser() {
        ref.child("users").child(CurrentUserModel.shared.uid).removeValue()
    }
}
