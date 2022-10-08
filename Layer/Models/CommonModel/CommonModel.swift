//
//  File.swift
//  Layer
//
//  Created by 박진서 on 2022/10/06.
//

import RxSwift
import RxCocoa
import NSObject_Rx
import UIKit
import FirebaseStorage

class ImageContainingType: NSObject {
    var profileImageUrl = BehaviorRelay<String?>(value: nil)
    let uid: String
    
    init(uid: String) {
        self.uid = uid
    }
    
    private func getImageUrl() -> Single<String> {
        return Single.create() { [unowned self] single in
            
            let imageRef = Storage.storage().reference().child("userImages").child(self.uid)
            imageRef.listAll { result, error in
                if let error = error {
                    print(error)
                    single(.error(error))
                } else {
                    if result!.items.count == 1 {
                        return result!.items.first!.downloadURL { url, error2 in
                            if let error2 = error2 {
                                single(.error(error2))
                            } else {
                                print("success")
                                single(.success(url!.absoluteString))
                            }
                        }
                    }
                }
            }
            
            return Disposables.create()
        }

    }
}

