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
    func delete() -> Completable
    func update() -> Completable
    
    
}

final class FrameManager: CommonBackendType, FrameManagerType {
    
    static let shared = FrameManager()
    
    let frameRelay = BehaviorRelay<[FrameModel]>(value: [])
    
    private override init(){}
    
    func fetchFirst() -> Completable {
        return Completable.create() { [unowned self] completable in
            ref.child("frame").queryLimited(toFirst: 5).observeSingleEvent(of: .value) { [unowned self] dataSnapShot in
                var temp = [FrameModel]()
                for data in dataSnapShot.children.allObjects as! [DataSnapshot] {
                    if let frameModel = FrameModel(snapshot: data) {
                        temp.append(frameModel)
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
                return Disposables.create()
            }
            
            ref.child("frame").queryStarting(afterValue: frameRelay.value.last!.uid).queryLimited(toFirst: 5).observeSingleEvent(of: .value) { dataSnapShot in
                var temp = [FrameModel]()
                for data in dataSnapShot.children.allObjects as! [DataSnapshot] {
                    if let frameModel = FrameModel(snapshot: data) {
                        temp.append(frameModel)
                    }
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
    
    func delete() -> Completable {
        return Completable.create() { [unowned self] completable in
            
            
            return Disposables.create()
        }
    }
    
    func update() -> Completable {
        return Completable.create() { [unowned self] completable in
            
            
            return Disposables.create()
        }
    }
    
}
