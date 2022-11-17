//
//  AuthManager.swift
//  Layer
//
//  Created by 박진서 on 2022/08/15.
//

import RxSwift
import RxCocoa
import NSObject_Rx
import FirebaseAuth
import FirebaseDatabase

final class AuthManager: CommonBackendType {
    static let shared = AuthManager()
    
    private override init() {}
    
    func fetch() -> Completable {
        return Completable.create() { [unowned self] completable in
            
            if let currentUser = Auth.auth().currentUser {
                ref.child("users").child(currentUser.uid)
                    .observeSingleEvent(of: .value) { DataSnapshot in
                        
                        if DataSnapshot.exists() {
                            CurrentUserModel.shared.setData(data: DataSnapshot)
                                .subscribe(onCompleted: {
                                    completable(.completed)
                                })
                                .disposed(by: self.rx.disposeBag)
                            
                        } else {
                            completable(.error(DataFetchingError.noData))
                        }
                    }
            } else {
                completable(.error(DataFetchingError.noData))
            }

            return Disposables.create()
        }
    }
    
    func fetchFriend() -> Completable {
        return Completable.create() { [unowned self] completable in
            ref.child("users").child(CurrentUserModel.shared.uid)
                .child("friends").observeSingleEvent(of: .value) { DataSnapShot in
                    var temp = [FriendModel]()
                    for data in DataSnapShot.children.allObjects as! [DataSnapshot] {
                        if let friendModel = FriendModel(data: data) {
                            temp.append(friendModel)
                        }
                    }
                    CurrentUserModel.shared.updateFriends(friends: temp)
                    completable(.completed)
                }

            return Disposables.create()
        }
    }
    
    func createUser(id: String, phoneNumber: String) {
        let currentUser = Auth.auth().currentUser!
        ref.child("users").child(currentUser.uid)
            .setValue(["name": id, "phoneNumber": phoneNumber])
        
        CurrentUserModel.shared.name = id
        CurrentUserModel.shared.phoneNumber = phoneNumber
        CurrentUserModel.shared.uid = currentUser.uid
    }
    
}
