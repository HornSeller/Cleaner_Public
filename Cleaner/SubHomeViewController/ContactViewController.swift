//
//  ContactViewController.swift
//  Cleaner
//
//  Created by Macmini on 25/10/2023.
//

import UIKit
import Contacts

class ContactViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        duplicateContacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! DuplicatedContactsTableViewCell
        
        return cell
    }
    

    @IBOutlet weak var tableView: UITableView!
    var duplicateContacts: [[ContactInfo]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "DuplicatedContactsTableViewCell", bundle: .main), forCellReuseIdentifier: "myCell")
        tableView.rowHeight = 0.21127 * view.frame.height
        
        getContacts() { contacts in
            var result: [[ContactInfo]] = []
            var currentIndex = 0
            var addedElement: [String] = []
            
            while currentIndex < contacts.count {
                let currentContact = contacts[currentIndex]
                var currentGroup: [ContactInfo] = [currentContact]
                
                var nextIndex = currentIndex + 1
                while nextIndex < contacts.count {
                    if contacts[nextIndex].phoneNumber == currentContact.phoneNumber && !addedElement.contains(currentContact.phoneNumber) {
                        currentGroup.append(contacts[nextIndex])
                    }
                    nextIndex += 1
                }
                
                if currentGroup.count >= 2 {
                    result.append(currentGroup)
                    addedElement.append(currentContact.phoneNumber)
                }
                
                currentIndex += 1
                if currentIndex == contacts.count {
                    self.duplicateContacts = result
                    print(self.duplicateContacts)
                    print(addedElement)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func getContacts(completion: @escaping ([ContactInfo]) -> Void) {
        // Tạo một đối tượng CNContactStore
        let contactStore = CNContactStore()
        
        // Kiểm tra quyền truy cập danh bạ
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            // Nếu đã có quyền, truy cập danh bạ và hiển thị thông tin liên hệ
            retrieveContacts(from: contactStore) { contacts in
                completion(contacts)
            }
        case .denied, .restricted:
            // Nếu bị từ chối hoặc hạn chế quyền, hiển thị một thông báo cho người dùng
            print("Access denied")
        case .notDetermined:
            // Nếu chưa được xác nhận, yêu cầu quyền truy cập danh bạ từ người dùng
            contactStore.requestAccess(for: .contacts) { [weak self] (granted, error) in
                if granted {
                    self?.retrieveContacts(from: contactStore) {contact in
                    }
                } else {
                    print("Access denied")
                }
            }
        }
    }
    
    func deleteContacts(contacts: [CNContact], completion: @escaping (Bool, Error?) -> Void) {
        let contactStore = CNContactStore()
        let saveRequest = CNSaveRequest()

        for contact in contacts {
            saveRequest.delete(contact.mutableCopy() as! CNMutableContact)
        }

        do {
            try contactStore.execute(saveRequest)
            completion(true, nil) // Xoá liên hệ thành công
        } catch {
            print("Error deleting contacts: \(error)")
            completion(false, error) // Xoá liên hệ thất bại, trả về lỗi
        }
    }

    func retrieveContacts(from contactStore: CNContactStore, completion: @escaping ([ContactInfo]) -> Void) {
        var contacts: [ContactInfo] = []
        DispatchQueue.global().async {
            let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
            let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch as [CNKeyDescriptor])
            
            do {
                try contactStore.enumerateContacts(with: fetchRequest) { (contact, stop) in
                    let givenName = contact.givenName
                    let familyName = contact.familyName
                    let phoneNumbers = contact.phoneNumbers.map { $0.value.stringValue }
                    // Lấy số điện thoại đầu tiên nếu có
                    if let phoneNumber = phoneNumbers.first {
                        let contactInfo = ContactInfo(name: "\(givenName) \(familyName)", phoneNumber: phoneNumber)
                        contacts.append(contactInfo)
                    }
                }
                // Gửi kết quả về luồng chính thông qua closure
                DispatchQueue.main.async {
                    completion(contacts)
                }
            } catch {
                // Xử lý lỗi nếu có
                print("Error fetching contacts: \(error)")
                // Gửi thông báo lỗi về luồng chính thông qua closure
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
    }
    
    static func makeSelf() -> ContactViewController {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let rootViewController: ContactViewController = storyboard.instantiateViewController(withIdentifier: "ContactViewController") as! ContactViewController
        
        return rootViewController
    }
}

struct ContactInfo {
    var name: String
    var phoneNumber: String
}
