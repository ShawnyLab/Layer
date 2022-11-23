//
//  SelectFrameViewController.swift
//  Layer
//
//  Created by 박진서 on 2022/10/04.
//

import UIKit
import PhotosUI
import Mantis

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
            .bind { [unowned self] Void in
                presentAlbum()
            }
            .disposed(by: rx.disposeBag)
        
    }
    
    func presentAlbum() {
        
        var configuration = PHPickerConfiguration() // 1.
        configuration.selectionLimit = 1 // 2.
        configuration.filter = .images // 3.
        let picker = PHPickerViewController(configuration: configuration)

        picker.delegate = self
        
        self.present(picker, animated: true)
    }
    
}

extension SelectFrameViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) { // 2.        
        picker.dismiss(animated: true, completion: nil) // 3.
        
        let itemProvider = results.first?.itemProvider // 4.
        if let itemProvider = itemProvider,
           itemProvider.canLoadObject(ofClass: UIImage.self) { // 5.
            itemProvider.loadObject(ofClass: UIImage.self) { image, error in // 6.
                DispatchQueue.main.async {
                    guard let selectedImage = image as? UIImage else { return }

                    let cropVC = Mantis.cropViewController(image: selectedImage)
                    cropVC.config.presetFixedRatioType = .alwaysUsingOnePresetFixedRatio(ratio: 375 / 275)
                
                    cropVC.delegate = self
                    self.present(cropVC, animated: true)
                }
            }
        }
        
        //Picker View Source https://velog.io/@wannabe_eung/%EC%95%A8%EB%B2%94%EC%9D%98-%EC%9D%B4%EB%AF%B8%EC%A7%80%EB%A5%BC-%EC%84%A0%ED%83%9D%ED%95%A0-%EC%88%98-%EC%9E%88%EB%8A%94-PHPickerViewController%EB%A5%BC-%EC%95%8C%EC%95%84%EB%B3%B4%EC%9E%90
    }
}

extension SelectFrameViewController: CropViewControllerDelegate {
    func cropViewControllerDidCrop(_ cropViewController: Mantis.CropViewController, cropped: UIImage, transformation: Mantis.Transformation, cropInfo: Mantis.CropInfo) {
        
        cropViewController
            .dismiss(animated: true) {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "addtextframeVC") as! AddTextFrameViewController
                self.frameUploadModel = FrameUploadModel()
                vc.frameUploadModel = self.frameUploadModel
                vc.image = cropped
                self.navigationController?.pushViewController(vc, animated: true)
            }
    }
    
    func cropViewControllerDidCancel(_ cropViewController: Mantis.CropViewController, original: UIImage) {
        cropViewController.dismiss(animated: true)
    }
    
    
}
