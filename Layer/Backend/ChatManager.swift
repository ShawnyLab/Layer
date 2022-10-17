//
//  ChatManager.swift
//  Layer
//
//  Created by 박진서 on 2022/10/13.
//

import RxSwift
import RxCocoa
import NSObject_Rx
import FirebaseDatabase

final class ChatManager: CommonBackendType {
    static let shared = ChatManager()
    
    private override init() {}
    
    func enterChatRoom(userId: String) -> Observable<[ChatModel]> {
        let roomId = [CurrentUserModel.shared.uid!, userId].sorted().joined()
        
        return Observable<[ChatModel]>.create() { [unowned self] chatObservable in
            var temp = [ChatModel]()
            ref.child("chatRoom").child(roomId)
                .observe(.value) { DataSnapshot in
                    temp.removeAll()
                    for data in DataSnapshot.children.allObjects as! [DataSnapshot] {
                        if let chatModel = ChatModel(data: data) {
                            temp.append(chatModel)
                        }
                    }
                    chatObservable.onNext(temp)
                }
            return Disposables.create()
        }
    }
    
    func send(userId: String, message: String, isTemp: Bool) -> ChatModel {
        let roomId = [CurrentUserModel.shared.uid!, userId].sorted().joined()
        
        let key = ref.child("chatRoom").child(roomId).childByAutoId().key!
        
        let createdAt = Date().dateTime
        
        ref.child("chatRoom").child(roomId).child(key)
            .setValue(["userId": CurrentUserModel.shared.uid, "message": message, "createdAt": createdAt])
        
        if isTemp {
            return ChatModel(message: message, userId: CurrentUserModel.shared.uid, createdAt: createdAt, dueDate: Date().after(hour: 1), uid: key)
        } else {
            return ChatModel(message: message, userId: CurrentUserModel.shared.uid, createdAt: createdAt, dueDate: nil, uid: key)
        }
    }
}
