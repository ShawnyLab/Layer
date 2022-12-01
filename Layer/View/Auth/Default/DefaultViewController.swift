//
//  DefaultViewController.swift
//  Layer
//
//  Created by 박진서 on 2022/08/15.
//

import UIKit
import AVKit

final class DefaultViewController: UIViewController {

    static let storyId = "defaultVC"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        



    }
    
    override func viewDidAppear(_ animated: Bool) {
        AuthManager.shared.fetch()
            .subscribe {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainVC") as! MainViewController
                let nav = UINavigationController(rootViewController: vc)
                nav.navigationBar.isHidden = true
                nav.modalPresentationStyle = .fullScreen
                nav.modalTransitionStyle = .crossDissolve
                self.present(nav, animated: true)
            } onError: { err in
                print(err)
                
                if !UserDefaults.standard.bool(forKey: "video") {
                    //https://moonibot.tistory.com/43
                    // 비디오 파일명을 사용하여 비디오가 저장된 앱 내부의 파일 경로를 받아옴
                    let filePath:String? = Bundle.main.path(forResource: "video", ofType: "mp4")
                    // 앱 내부의 파일명을 NSURL 형식으로 변경
                    let url = NSURL(fileURLWithPath: filePath!)
                    
                    self.playVideo(url: url) // 앞에서 얻은 url을 사용하여 비디오를 재생
                    
                }
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "signinVC") as! SignInViewController
                self.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: rx.disposeBag)
    }
    
    private func playVideo(url: NSURL) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "playerVC") as! PlayerViewController
        // 비디오 URL로 초기화된 AVPlayer의 인스턴스 생성
        let player = AVPlayer(url: url as URL)
        // AVPlayerViewController의 player 속성에 위에서 생성한 AVPlayer 인스턴스를 할당
        vc.player = player
        vc.videoGravity = .resizeAspectFill
        
        self.present(vc, animated: true) {
            player.play() // 비디오 재생
        }        
    }
    
    
}
