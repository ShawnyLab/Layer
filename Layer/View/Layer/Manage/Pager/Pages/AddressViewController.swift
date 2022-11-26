//
//  AddressViewController.swift
//  Layer
//
//  Created by 박진서 on 2022/10/12.
//

import UIKit
import Contacts
import RxSwift
import RxCocoa
import NSObject_Rx

class AddressViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    // https://myseong.tistory.com/6, https://g-y-e-o-m.tistory.com/19
    let keywordRelay = BehaviorRelay<String?>(value: nil)

    let store = CNContactStore()
    
    var original = [CNContact]()
    var contacts = [CNContact]()
    
    var startLoading: (() -> Void)!
    var stopLoading: (() -> Void)!
    var endEdit: (() -> Void)!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        keywordRelay
            .subscribe(onNext: { [unowned self] str in
                if let str {
                    if str.count > 0 {
                        contacts = original.filter{ $0.givenName.contains(str) || $0.familyName.contains(str) || $0.middleName.contains(str)}
                        self.tableView.reloadData()
                    }
                }
            })
            .disposed(by: rx.disposeBag)
        
        
        let keys = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactPhoneNumbersKey as CNKeyDescriptor]

        // 주소록에서 가져올 데이터들의 옵션을 저장하는 객체
        let request = CNContactFetchRequest(keysToFetch: keys)

        store.requestAccess(for: .contacts, completionHandler: {
            (granted , err) in
            //권한 허용 시
            if(granted){
                do {
                    try self.store.enumerateContacts(with: request) {
                    (contact, stop) in
                        // 이름은 있으나 폰 번호가 없는 경우
                        if !contact.phoneNumbers.isEmpty {
                            self.contacts.append(contact)
                        }
                    }
                } catch {
                    print("unable to fetch contacts")
                }
                self.original = self.contacts
            }
            // 권한 비 허용 시
            else {
                let toast = UIAlertController(title: "알림", message: "주소록 권한이 필요합니다.", preferredStyle: .alert)
                toast.addAction(UIAlertAction(title: "확인", style: .default, handler: {
                    (Action) -> Void in
                    let settingsURL = NSURL(string: UIApplication.openSettingsURLString)! as URL
                    UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                }))
                self.present(toast, animated: true, completion: nil)
            }
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.endEdit!()
    }

}

extension AddressViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: AddressCell.reuseId, for: indexPath) as! AddressCell
        cell.nameLabel.text = contacts[indexPath.row].familyName + contacts[indexPath.row].givenName
        
        if let number = contacts[indexPath.row].phoneNumbers[0].value.value(forKey: "digits") {
            cell.numberLabel.text = "\(number)"
            
            UserManager.shared.checkNumber(number: "\(number)")
                .subscribe(onSuccess: { [unowned self] uid in
                    if let uid {
                        cell.inviteButton.isHidden = true
                        cell.requestButton.isHidden = false
                        
                        cell.buttonHandler = {
                            self.startLoading!()
                            
                            UserManager.shared.fetch(id: uid)
                                .subscribe(onSuccess: { [unowned self] userModel in
                                    self.stopLoading!()
                                    self.openUserProfile(userModel: userModel)
                                })
                                .disposed(by: self.rx.disposeBag)
                        }
                        
                    } else {
                        cell.requestButton.isHidden = true
                        cell.inviteButton.isHidden = false
                    }
                })
                .disposed(by: rx.disposeBag)

        }
        

        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contacts.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 71
    }
    
}


final class AddressCell: UITableViewCell {
    static let reuseId = "addressCell"
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var requestButton: UIButton!

    @IBOutlet weak var profileImageView: UIImageView!
    
    var buttonHandler: (() -> Void)!
    override func awakeFromNib() {
        inviteButton.layer.cornerRadius = 13
        requestButton.layer.cornerRadius = 13
        
        inviteButton.layer.borderWidth = 1
        inviteButton.layer.borderColor = UIColor.black.cgColor
        profileImageView.circular()
        self.selectionStyle = .none
        
    }
    
    @IBAction func request(_ sender: Any) {
        buttonHandler!()
    }
}
