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
    
    private var layerType: LayerType = .white
    
    var reportedUser: [String: Bool] = UserDefaults.standard.dictionary(forKey: "reportedUser") as? [String: Bool] ?? [:]
    
    private override init(){}
    
    func fetchLayer(layer: LayerType) -> Completable {
        self.layerType = layer
        return Completable.create() { [unowned self] completable in
            ref.child("frame").queryOrderedByKey().queryLimited(toLast: 10).observeSingleEvent(of: .value) { [unowned self] dataSnapShot in
                var temp = [FrameModel]()
                for data in dataSnapShot.children.allObjects as! [DataSnapshot] {
                    if let frameModel = FrameModel(snapshot: data) {
                        
                        if reportedUser[frameModel.writerId] != true {
                            
                            
                            if frameModel.dueDate != nil && frameModel.dueDate! < Date().dateTime {
                                self.ref.child("frame").child(frameModel.uid).removeValue()
                            } else {
                                
                                let writerLayer = (CurrentUserModel.shared.friendsHash[frameModel.writerId] ?? -30)/10
                                
                                let myLayerFromWriter = (CurrentUserModel.shared.friendsHash[frameModel.writerId] ?? -3)%10
                                
                                var canShow = false
                                
                                if frameModel.layer == 7 {
                                    canShow = true
                                } else if (frameModel.layer == 6 && myLayerFromWriter == 1) || (frameModel.layer == 6 && myLayerFromWriter == 2) {
                                    canShow = true
                                } else if (frameModel.layer == 5 && myLayerFromWriter == 0) || (frameModel.layer == 5 && myLayerFromWriter == 2) {
                                    canShow = true
                                } else if (frameModel.layer == 4 && myLayerFromWriter == 2) {
                                    canShow = true
                                } else if (frameModel.layer == 3 && myLayerFromWriter == 0) || (frameModel.layer == 3 && myLayerFromWriter == 1) {
                                    canShow = true
                                } else if (frameModel.layer == 2 && myLayerFromWriter == 1) {
                                    canShow = true
                                } else if (frameModel.layer == 1 && myLayerFromWriter == 0) {
                                    canShow = true
                                }
                                
                                
                                
                                switch layer {
                                case .white:
                                    if (writerLayer >= 0 && canShow) || frameModel.writerId == CurrentUserModel.shared.uid {
                                        temp.insert(frameModel, at: 0)
                                    }
                                case .gray:
                                    if (writerLayer >= 1 && canShow) || frameModel.writerId == CurrentUserModel.shared.uid {
                                        temp.insert(frameModel, at: 0)
                                    }
                                case .black:
                                    if (writerLayer >= 2 && canShow) || frameModel.writerId == CurrentUserModel.shared.uid {
                                        temp.insert(frameModel, at: 0)
                                    }
                                }
                            }
                            

                        }

                    }
                }
                frameRelay.accept(temp)
                completable(.completed)
            }
            return Disposables.create()
        }
    }
    
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
                    var temp = [FrameModel]()
                    for data in dataSnapShot.children.allObjects as! [DataSnapshot] {
                        if let frameModel = FrameModel(snapshot: data) {
                            if reportedUser[frameModel.writerId] != true {
                                let writerLayer = (CurrentUserModel.shared.friendsHash[frameModel.writerId] ?? -30)/10
                                
                                let myLayerFromWriter = (CurrentUserModel.shared.friendsHash[frameModel.writerId] ?? -3)%10
                                
                                if frameModel.dueDate != nil && frameModel.dueDate! < Date().dateTime {
                                    self.ref.child("frame").child(frameModel.uid).removeValue()
                                } else {
                                    var canShow = false
                                    
                                    if frameModel.layer == 7 {
                                        canShow = true
                                    } else if (frameModel.layer == 6 && myLayerFromWriter == 1) || (frameModel.layer == 6 && myLayerFromWriter == 2) {
                                        canShow = true
                                    } else if (frameModel.layer == 5 && myLayerFromWriter == 0) || (frameModel.layer == 5 && myLayerFromWriter == 2) {
                                        canShow = true
                                    } else if (frameModel.layer == 4 && myLayerFromWriter == 2) {
                                        canShow = true
                                    } else if (frameModel.layer == 3 && myLayerFromWriter == 0) || (frameModel.layer == 3 && myLayerFromWriter == 1) {
                                        canShow = true
                                    } else if (frameModel.layer == 2 && myLayerFromWriter == 1) {
                                        canShow = true
                                    } else if (frameModel.layer == 1 && myLayerFromWriter == 0) {
                                        canShow = true
                                    }
                                    
                                    
                                    
                                    switch self.layerType {
                                    case .white:
                                        if (writerLayer >= 0 && canShow) || frameModel.isOpened || frameModel.writerId == CurrentUserModel.shared.uid {
                                            temp.insert(frameModel, at: 0)
                                        }
                                    case .gray:
                                        if (writerLayer >= 1 && canShow) || frameModel.writerId == CurrentUserModel.shared.uid {
                                            temp.insert(frameModel, at: 0)
                                        }
                                    case .black:
                                        if (writerLayer >= 2 && canShow) || frameModel.writerId == CurrentUserModel.shared.uid {
                                            temp.insert(frameModel, at: 0)
                                        }
                                    }
                                }
                                

                            }

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
    
    func reportUser(userId: String) {
        reportedUser[userId] = true
        UserDefaults.standard.set(reportedUser, forKey: "reportedUser")
    }
}
