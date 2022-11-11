//
//  MainPageViewController.swift
//  Layer
//
//  Created by 박진서 on 2022/07/27.
//

import UIKit
import RxRelay

class MainPageViewController: UIPageViewController {
    static let storyId = "mainpageVC"
    private var vcList = [UIViewController]()
    var mainVC: MainViewController!
    
    let layerRelay = BehaviorRelay<LayerType>(value: .white)
        
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let layerVC = UIStoryboard(name: "Layer", bundle: nil).instantiateViewController(withIdentifier: "layerVC") as? LayerViewController else { return }
        layerRelay
            .bind(to: layerVC.layerRelay)
            .disposed(by: rx.disposeBag)
        vcList.append(layerVC)
        
        guard let messageVC = UIStoryboard(name: "Message", bundle: nil).instantiateViewController(withIdentifier: MessageViewController.storyId) as? MessageViewController else { return }
        layerRelay
            .bind(to: messageVC.layerRelay)
            .disposed(by: rx.disposeBag)
        vcList.append(messageVC)
        
        guard let profileVC = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: ProfileViewController.storyId) as? ProfileViewController else { return }
        layerRelay
            .bind(to: profileVC.layerRelay)
            .disposed(by: rx.disposeBag)
        vcList.append(profileVC)
        
        self.dataSource = self
        self.delegate = self
        
        if let firstviewController = vcList.first {
            setViewControllers([firstviewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
        
        
    }

}

extension MainPageViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = vcList.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard vcList.count > previousIndex else {
            return nil
        }
        return vcList[previousIndex]
        
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = vcList.firstIndex(of: viewController) else {
            return nil
        }

        let nextIndex = viewControllerIndex + 1

        guard vcList.count != nextIndex else {
            return nil
        }

        guard vcList.count > nextIndex else {
            return nil
        }

        return vcList[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        var currentIndex: Int {
            guard let vc = viewControllers?.first else { return 0 }
            return vcList.firstIndex(of: vc) ?? 0
        }
        mainVC.pageRelay.accept(currentIndex)
    }
}
