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
                            if chatModel.uid != "lastMessage" {
                                temp.append(chatModel)
                            }
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
        
        var dueDate: String? = nil
        
        if isTemp {
            dueDate = Date().after(hour: 1)
        }
        
        ref.child("chatRoom").child(roomId).child(key)
            .setValue(["userId": CurrentUserModel.shared.uid, "message": message, "createdAt": createdAt, "dueDate": dueDate])
        
        ref.child("chatRoom").child(roomId).child("lastMessage")
            .setValue(["userId": CurrentUserModel.shared.uid, "message": message, "createdAt": createdAt, "dueDate": dueDate])
        
        return ChatModel(message: message, userId: CurrentUserModel.shared.uid, createdAt: createdAt, dueDate: dueDate, uid: key)
        

    }
    
    func fetchRooms() -> Observable<[ChatRoomModel]> {
        return Observable<[ChatRoomModel]>.create() { [unowned self] chatRoomObservable in
            
            ref.child("findRoom").child(CurrentUserModel.shared.uid)
                .observeSingleEvent(of: .value) { DataSnapshot in
                    if DataSnapshot.exists() {
                        var temp = [ChatRoomModel]()
                        
                        for data in DataSnapshot.children.allObjects as! [DataSnapshot] {
                            let roomId = data.value as! String

                            self.observeLastMessage(roomId: roomId)
                                .subscribe(onNext: { [unowned self] roomModel in
                                    if temp.contains(roomModel) {
                                        let idx = temp.firstIndex(where: {$0.uid == roomModel.uid})!
                                        temp[idx].lastMessage = roomModel.lastMessage
                                    } else {
                                        temp.insert(roomModel, at: 0)
                                    }
                                    chatRoomObservable.onNext(temp.sorted(by: {$0.lastMessage!.createdAt > $1.lastMessage!.createdAt}))
                                })
                                .disposed(by: self.rx.disposeBag)
                        }
                    } else {
                        chatRoomObservable.onNext([])
                    }
                }
            
            
            return Disposables.create()
        }
    }
    
    func observeLastMessage(roomId: String) -> Observable<ChatRoomModel> {
        return Observable<ChatRoomModel>.create() { [unowned self] roomObservable in
            
            ref.child("chatRoom").child(roomId).child("lastMessage")
                .observe(.value) { DataSnapshot in
                    if DataSnapshot.exists() {
                        if let lastMessage = ChatModel(data: DataSnapshot) {
                            let model = ChatRoomModel(lastMessage: lastMessage, uid: roomId)
                            roomObservable.onNext(model)
                        } else {
                            roomObservable.onError(DataFetchingError.noData)
                        }
                    } else {
                        roomObservable.onError(DataFetchingError.noData)
                    }
                }
            return Disposables.create()
        }
    }
    
    func createChatRoom(userId: String) {
        let roomId = [CurrentUserModel.shared.uid!, userId].sorted().joined()
        ref.child("findRoom").child(CurrentUserModel.shared.uid).child(roomId).setValue(roomId)
        ref.child("findRoom").child(userId).child(roomId).setValue(roomId)
    }
}
