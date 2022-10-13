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
}
