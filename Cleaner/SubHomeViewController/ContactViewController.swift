//
//  ContactViewController.swift
//  Cleaner
//
//  Created by Macmini on 25/10/2023.
//

import UIKit
import Contacts

class ContactViewController: UIViewController {

    var duplicateContacts: [[ContactInfo]] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
}

struct ContactInfo {
    var name: String
    var phoneNumber: String
}
