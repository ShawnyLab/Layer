//
//  LayerManageViewController.swift
//  Layer
//
//  Created by 박진서 on 2022/10/12.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class LayerManageViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var inviteView: UIView!
    
    @IBOutlet weak var addressView: UIView!
    @IBOutlet weak var mylayerView: UIView!
    @IBOutlet weak var requestView: UIView!
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mylayerLabel: UILabel!
    @IBOutlet weak var requestLabel: UILabel!
    
    
    private var vcList = [UIViewController]()
    let pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    
    private let pageIndex = BehaviorRelay(value: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        inviteView.layer.cornerRadius = 13
        inviteView.layer.borderWidth = 1
        inviteView.layer.borderColor = UIColor(red: 153, green: 153, blue: 153).cgColor

        pageIndex
            .subscribe(onNext: { [unowned self] idx in
                if idx == 0 {
                    addressView.isHidden = false
                    mylayerView.isHidden = true
                    requestView.isHidden = true
                    
                    addressLabel.font = UIFont.myBoldSystemFont(ofSize: 12)
                    mylayerLabel.font = UIFont.mySystemFont(ofSize: 12)
                    requestLabel.font = UIFont.mySystemFont(ofSize: 12)
                    
                    
                } else if idx == 1 {
                    addressView.isHidden = true
                    mylayerView.isHidden = false
                    requestView.isHidden = true
                    
                    addressLabel.font = UIFont.mySystemFont(ofSize: 12)
                    mylayerLabel.font = UIFont.myBoldSystemFont(ofSize: 12)
                    requestLabel.font = UIFont.mySystemFont(ofSize: 12)
                } else if idx == 2 {
                    addressView.isHidden = true
                    mylayerView.isHidden = false
                    requestView.isHidden = true
                    
                    addressLabel.font = UIFont.mySystemFont(ofSize: 12)
                    mylayerLabel.font = UIFont.mySystemFont(ofSize: 12)
                    requestLabel.font = UIFont.myBoldSystemFont(ofSize: 12)
                }
            })
            .disposed(by: rx.disposeBag)
        
        
        
        
        guard let layerVC = UIStoryboard(name: "Manage", bundle: nil).instantiateViewController(withIdentifier: "addressVC") as? AddressViewController else { return }
        vcList.append(layerVC)
        
        guard let messageVC = UIStoryboard(name: "Manage", bundle: nil).instantiateViewController(withIdentifier: "mylayerVC") as? MyLayerViewController else { return }
        vcList.append(messageVC)
        
        guard let requestVC = UIStoryboard(name: "Manage", bundle: nil).instantiateViewController(withIdentifier: "requestVC") as? RequestViewController else { return }
        vcList.append(requestVC)
        
        pageVC.dataSource = self
        pageVC.delegate = self
        
        if let firstviewController = vcList.first {
            pageVC.setViewControllers([firstviewController],
                               direction: .forward,
                               animated: false,
                               completion: nil)
        }
        addChild(pageVC)
        pageVC.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(pageVC.view)
    }
}

extension LayerManageViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
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
            guard let vc = pageVC.viewControllers?.first else { return 0 }
            return vcList.firstIndex(of: vc) ?? 0
        }
        pageIndex.accept(currentIndex)
    }
    
}
