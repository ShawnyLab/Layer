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

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var inviteView: UIView!
    
    @IBOutlet weak var addressView: UIView!
    @IBOutlet weak var mylayerView: UIView!
    @IBOutlet weak var requestView: UIView!
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mylayerLabel: UILabel!
    @IBOutlet weak var requestLabel: UILabel!
    
    @IBOutlet weak var searchBarContainer: UIView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    @IBOutlet weak var addressButton: UIButton!
    @IBOutlet weak var layerButton: UIButton!
    @IBOutlet weak var requestButton: UIButton!
    @IBOutlet weak var inviteButton: UIButton!
    
    
    private var vcList = [UIViewController]()
    let pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    
    private let pageIndex = BehaviorRelay(value: 0)
    
    private let keywordRelay = BehaviorRelay<String?>(value: nil)

    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchTextField.rx.text
            .bind(to: keywordRelay)
            .disposed(by: rx.disposeBag)
        
        searchBarContainer.layer.cornerRadius = 13

        inviteView.layer.cornerRadius = 13
        inviteView.layer.borderWidth = 1
        inviteView.layer.borderColor = UIColor(red: 153, green: 153, blue: 153).cgColor
        indicator.isHidden = true

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
                    mylayerView.isHidden = true
                    requestView.isHidden = false
                    
                    addressLabel.font = UIFont.mySystemFont(ofSize: 12)
                    mylayerLabel.font = UIFont.mySystemFont(ofSize: 12)
                    requestLabel.font = UIFont.myBoldSystemFont(ofSize: 12)
                }
            })
            .disposed(by: rx.disposeBag)
        
        
        
        
        guard let addressVC = UIStoryboard(name: "Manage", bundle: nil).instantiateViewController(withIdentifier: "addressVC") as? AddressViewController else { return }
        keywordRelay.bind(to: addressVC.keywordRelay)
            .disposed(by: rx.disposeBag)
        
        addressVC.startLoading = {
            self.indicator.isHidden = false
            self.indicator.startAnimating()
        }
        
        addressVC.stopLoading = {
            self.indicator.isHidden = true
            self.indicator.stopAnimating()
        }
        
        addressVC.endEdit = {
            self.view.endEditing(true)
        }
        
        vcList.append(addressVC)
        
        guard let layerVC = UIStoryboard(name: "Manage", bundle: nil).instantiateViewController(withIdentifier: "mylayerVC") as? MyLayerViewController else { return }
        vcList.append(layerVC)
        keywordRelay.bind(to: layerVC.keywordRelay)
            .disposed(by: rx.disposeBag)
        
        guard let requestVC = UIStoryboard(name: "Manage", bundle: nil).instantiateViewController(withIdentifier: "requestVC") as? RequestViewController else { return }
        vcList.append(requestVC)
        keywordRelay.bind(to: requestVC.keywordRelay)
            .disposed(by: rx.disposeBag)
        
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
        
        addressButton.rx.tap
            .bind { [unowned self] _ in
                containerView.addSubview(addressVC.view)
                addressVC.didMove(toParent: self)
                pageIndex.accept(0)
                
            }
            .disposed(by: rx.disposeBag)
        
        layerButton.rx.tap
            .bind { [unowned self] _ in
                containerView.addSubview(layerVC.view)
                layerVC.didMove(toParent: self)
                pageIndex.accept(1)
                
            }
            .disposed(by: rx.disposeBag)
        
        requestButton.rx.tap
            .bind { [unowned self] _ in
                containerView.addSubview(requestVC.view)
                requestVC.didMove(toParent: self)
                pageIndex.accept(2)
                
            }
            .disposed(by: rx.disposeBag)
        
        inviteButton.rx.tap
            .bind { [unowned self] _ in
                //https://maivve.tistory.com/175
                let items: [Any] = [UIImage(named: "LayerIcon")!]
                
                let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
                activityVC.popoverPresentationController?.sourceView = self.view
                
                self.present(activityVC, animated: true, completion: nil)
            }
            .disposed(by: rx.disposeBag)
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
