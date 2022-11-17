//
//  LayerViewModel.swift
//  Layer
//
//  Created by 박진서 on 2022/07/30.
//

import RxSwift
import RxCocoa

class LayerViewModel: NSObject {
    
    let layerStatus = BehaviorRelay<LayerType>(value: .white)
    let frameRelay = BehaviorRelay<[FrameModel]>(value: [])
    
    override init() {
        super.init()
        
        reload()
        
        FrameManager.shared.frameRelay
            .bind(to: frameRelay)
            .disposed(by: rx.disposeBag)
    }
    
    func reload() {
        layerStatus.subscribe { [unowned self] layerType in
            FrameManager.shared.fetchLayer(layer: layerType)
                .subscribe {
                    print("fetch")
                } onError: { err in
                    print(err)
                }
                .disposed(by: rx.disposeBag)
        }
        .disposed(by: rx.disposeBag)

    }
    
    func fetchMore() -> Completable {
        return Completable.create() { [unowned self] completable in
            
            FrameManager.shared.fetchMore()
                .subscribe(onCompleted: {
                    completable(.completed)
                }) { error in
                    print("error: \(error)")
                    completable(.error(error))
                }
                .disposed(by: rx.disposeBag)
            
            return Disposables.create()
        }

    }
    
    func fetchUserModel(idx: Int) -> Single<UserModel> {
        return UserManager.shared.fetch(id: frameRelay.value[idx].writerId)
    }
    
}
