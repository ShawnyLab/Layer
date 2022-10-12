//
//  ManagePagerViewController.swift
//  Layer
//
//  Created by 박진서 on 2022/10/12.
//

import UIKit

class ManagePagerViewController: UIPageViewController {

    static let storyId = "managepagerVC"
    private var vcList = [UIViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let layerVC = UIStoryboard(name: "Manage", bundle: nil).instantiateViewController(withIdentifier: "addressVC") as? AddressViewController else { return }
        vcList.append(layerVC)
        
        guard let messageVC = UIStoryboard(name: "Manage", bundle: nil).instantiateViewController(withIdentifier: "mylayerVC") as? MyLayerViewController else { return }
        vcList.append(messageVC)
        
        guard let requestVC = UIStoryboard(name: "Manage", bundle: nil).instantiateViewController(withIdentifier: "requestVC") as? RequestViewController else { return }
        vcList.append(requestVC)
        
        self.dataSource = self
        self.delegate = self
        
        if let firstviewController = vcList.first {
            setViewControllers([firstviewController],
                               direction: .forward,
                               animated: false,
                               completion: nil)
        }
        
        
    }
    

}

extension ManagePagerViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
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
//        mainVC.pageRelay.accept(currentIndex)
    }
}
