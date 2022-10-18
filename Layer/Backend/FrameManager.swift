//
//  FrameManager.swift
//  Layer
//
//  Created by 박진서 on 2022/08/10.
//

import FirebaseDatabase
import RxSwift
import RxCocoa
import NSObject_Rx

protocol FrameManagerType {
    func fetchFirst() -> Completable
    func fetchMore() -> Completable
    func fetchById(id: String) -> Single<FrameModel>
    func create() -> Completable
    func delete(uid: String) -> Completable
    func update() -> Completable
    
    
}

final class FrameManager: CommonBackendType, FrameManagerType {
    
    static let shared = FrameManager()
    
    let frameRelay = BehaviorRelay<[FrameModel]>(value: [])
    
    private override init(){}
    
    func fetchFirst() -> Completable {
        return Completable.create() { [unowned self] completable in
            ref.child("frame").queryOrderedByKey().queryLimited(toLast: 5).observeSingleEvent(of: .value) { [unowned self] dataSnapShot in
                var temp = [FrameModel]()
                for data in dataSnapShot.children.allObjects as! [DataSnapshot] {
                    if let frameModel = FrameModel(snapshot: data) {
                        temp.insert(frameModel, at: 0)
                    }
                }
                frameRelay.accept(temp)
                completable(.completed)
            }
            return Disposables.create()
        }
    }
    
    func fetchMore() -> Completable {
        return Completable.create() { [unowned self] completable in
            if frameRelay.value.isEmpty {
                completable(.error(DataFetchingError.noData))
                return Disposables.create()
            }
            
            ref.child("frame").queryOrderedByKey().queryEnding(beforeValue: frameRelay.value.last!.uid).queryLimited(toLast: 5).observeSingleEvent(of: .value) { [unowned self] dataSnapShot in
                
                if dataSnapShot.exists() {
                    print("==========================")
                    print(dataSnapShot)
                    var temp = [FrameModel]()
                    for data in dataSnapShot.children.allObjects as! [DataSnapshot] {
                        if let frameModel = FrameModel(snapshot: data) {
                            temp.insert(frameModel, at: 0)
                        }
                    }
                    
                    frameRelay.accept(frameRelay.value + temp)
                    completable(.completed)
                } else {
                    completable(.error(DataFetchingError.noData))
                }

            }
            
            return Disposables.create()
        }
    }
    
    func fetchById(id: String) -> Single<FrameModel> {
        return Single.create() { [unowned self] single in
            
            
            return Disposables.create()
        }
    }
    
    func create() -> Completable {
        return Completable.create() { [unowned self] completable in
            
            
            return Disposables.create()
        }
    }
    
    func delete(uid: String) -> Completable {
        return Completable.create() { [unowned self] completable in
            if let idx = frameRelay.value.firstIndex(where: {$0.uid == uid}) {
                var newList = frameRelay.value
                newList.remove(at: idx)
                frameRelay.accept(newList)
                
                ref.child("frame").child(uid).removeValue()
                ref.child("users").child(CurrentUserModel.shared.uid).child("frames").child(uid).removeValue()
                
                CurrentUserModel.shared.frames[uid] = nil
                let idx = CurrentUserModel.shared.frameModels.firstIndex(where: {$0.uid == uid})!
                CurrentUserModel.shared.frameModels.remove(at: idx)
                completable(.completed)
            } else {
                completable(.error(DataFetchingError.noData))
            }
            
            return Disposables.create()
        }
    }
    
    func update() -> Completable {
        return Completable.create() { [unowned self] completable in
            
            
            return Disposables.create()
        }
    }
    
}
