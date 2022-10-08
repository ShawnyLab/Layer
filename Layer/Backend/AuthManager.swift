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
                            completable(.completed)
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
    
    func fetchFriend() {
        
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
