//
//  LayerViewModel.swift
//  Layer
//
//  Created by 박진서 on 2022/07/30.
//

import RxSwift
import RxCocoa

class LayerViewModel: NSObject {
    
    let frameRelay = BehaviorRelay<[FrameModel]>(value: [])
    
    override init() {
        super.init()
        
        reload()
        
        FrameManager.shared.frameRelay
            .bind(to: frameRelay)
            .disposed(by: rx.disposeBag)
    }
    
    func reload() {
        FrameManager.shared.fetchFirst()
            .subscribe {
                print("fetch")
            } onError: { err in
                print(err)
            }
            .disposed(by: rx.disposeBag)

    }
    
    func fetchUserModel(idx: Int) -> Single<UserModel> {
        return UserManager.shared.fetch(id: frameRelay.value[idx].writerId)
    }
}
