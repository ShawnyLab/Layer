//
//  SelectFrameViewController.swift
//  Layer
//
//  Created by 박진서 on 2022/10/04.
//

import UIKit

class SelectFrameViewController: AddFrameType {
    static let storyId = "selectframeVC"

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var textFrameButton: UIButton!
    @IBOutlet weak var imageFrameButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                navigationController?.popViewController(animated: true)
            })
            .disposed(by: rx.disposeBag)
        
        textFrameButton.rx.tap
            .bind { [unowned self] Void in
                self.frameUploadModel = FrameUploadModel()
                let vc = storyboard?.instantiateViewController(withIdentifier: "addtextframeVC") as! AddTextFrameViewController
                vc.frameUploadModel = frameUploadModel
                self.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: rx.disposeBag)
        
        imageFrameButton.rx.tap
            .bind { Void in
                
            }
            .disposed(by: rx.disposeBag)
        
    }
    
}
