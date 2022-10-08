//
//  CommonBackendType.swift
//  Layer
//
//  Created by 박진서 on 2022/08/10.
//

import FirebaseDatabase


class CommonBackendType: NSObject {
    let ref = Database.database(url: "https://layer-8e3e6-default-rtdb.asia-southeast1.firebasedatabase.app").reference()
}
