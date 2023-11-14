//
//  ContactViewController.swift
//  Cleaner
//
//  Created by Macmini on 25/10/2023.
//

import UIKit
import Contacts

class ContactViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SelectionCellDelegate {
    func callFunction() {
        self.updateInfoLabel()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        duplicateContacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! DuplicatedContactsTableViewCell
        cell.dataCollectionView = duplicateContacts[indexPath.row]
        cell.collectionView.reloadData()
        return cell
    }

    @IBOutlet weak var infoLb: UILabel!
    @IBOutlet weak var backgroundLb: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var duplicateContacts: [[ContactInfo]] = []
    var foundContacts = 0
    public static var selectedDuplicatedContacts: [ContactInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deleteBtn.layer.cornerRadius = 22
        
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
                    self.foundContacts += currentGroup.count
                    addedElement.append(currentContact.phoneNumber)
                }
                
                currentIndex += 1
                if currentIndex == contacts.count {
                    self.duplicateContacts = result
                    if self.duplicateContacts.count > 0 {
                        self.backgroundImageView.isHidden = true
                        self.backgroundLb.isHidden = true
                        print(self.foundContacts)
                        self.infoLb.text = "0/\(self.foundContacts) selected contact(s)"
                    }
                    print(addedElement)
                    self.tableView.reloadData()
                }
            }
        }
    }

    func updateInfoLabel() {
        self.infoLb.text = "\(ContactViewController.selectedDuplicatedContacts.count)/\(self.foundContacts) selected contact(s)"
        print("\(ContactViewController.selectedDuplicatedContacts.count)/\(self.foundContacts) selected contact(s)")
    }
    
    @IBAction func deleteBtnTapped(_ sender: UIButton) {
        print(ContactViewController.selectedDuplicatedContacts)
        let contactStore = CNContactStore()
        var contactToDelete: [CNContact] = []
        var indexPathsToDelete: [IndexPath] = []
        var sectionToDelete: [Int] = []
        if ContactViewController.selectedDuplicatedContacts.count == 0 {
            let alert = UIAlertController(title: "Please choose at least 1 Contact to delete", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
            return
        }
        
        let alert = UIAlertController(title: "Do you really want to delete this \(ContactViewController.selectedDuplicatedContacts.count) contact(s)?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (_) in
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
                            if ContactViewController.selectedDuplicatedContacts.contains(where: {$0 == contactInfo}) {
                                contactToDelete.append(contact)
                            }
                        }
                    }
                    
                    if contactToDelete.count == ContactViewController.selectedDuplicatedContacts.count {
                        for (section, sectionContacts) in self.duplicateContacts.enumerated() {
                            var count = 0
                            for (row, contactInfo) in sectionContacts.enumerated() {
                                if ContactViewController.selectedDuplicatedContacts.contains(where: {$0 == contactInfo}) {
                                    count += 1
                                    let indexPath = IndexPath(row: row, section: section)
                                    if count < sectionContacts.count - 1 {
                                        indexPathsToDelete.append(indexPath)
                                    } else {
                                        indexPathsToDelete.append(indexPath)
                                        if !sectionToDelete.contains(section) {
                                            sectionToDelete.append(section)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    print("\(sectionToDelete) & \(indexPathsToDelete)")
                    self.deleteContacts(contacts: contactToDelete) { success, error in
                        if success {
                            for indexPath in indexPathsToDelete.reversed() {
                                self.duplicateContacts[indexPath.section].remove(at: indexPath.row)
                            }
                            
                            for section in sectionToDelete.reversed() {
                                self.duplicateContacts.remove(at: section)
                            }
                            
                            DispatchQueue.main.async {
                                let alert = UIAlertController(title: "Delete successfully!", message: nil, preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default))
                                self.present(alert, animated: true )
                                self.tableView.reloadDataAndPerformCustomLogic()
                                if self.duplicateContacts.count == 0 {
                                    self.backgroundLb.isHidden = false
                                    self.backgroundImageView.isHidden = false
                                }
                            }
                        }
                    }
                } catch {
                    // Xử lý lỗi nếu có
                    print("Error fetching contacts: \(error)")
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        self.present(alert, animated: true)
    }
    
    @IBAction func backBtnTapped(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
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
    
    static func == (lhs: ContactInfo, rhs: ContactInfo) -> Bool {
        // So sánh các thuộc tính của cặp (UIImage, PHAsset)
        return lhs.name == rhs.name && lhs.phoneNumber == rhs.phoneNumber
    }
}
