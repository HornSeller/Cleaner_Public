//
//  PrivateBrowserViewController.swift
//  Cleaner
//
//  Created by Mac on 20/09/2023.
//

import UIKit

class PrivateBrowserViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).font = UIFont.systemFont(ofSize: 18)
        
        if let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField {
            let placeholderAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor(red: 151/255, green: 166/255, blue: 175/255, alpha: 1), // Màu sắc mong muốn
                .font: UIFont.systemFont(ofSize: 18) // Font chữ mong muốn
            ]
            textFieldInsideSearchBar.attributedPlaceholder = NSAttributedString(string: "Enter URL address", attributes: placeholderAttributes)
        }
        
        searchBar.searchTextField.layer.cornerRadius = 24
        searchBar.searchTextField.layer.masksToBounds = true
        
        searchBar.searchTextField.leftView?.backgroundColor = UIColor.clear
        searchBar.searchTextField.leftView?.tintColor = UIColor.clear
        searchBar.searchTextField.leftView?.frame = CGRect(x: 0, y: 0, width: 20, height: 20) // Điều chỉnh kích thước nếu cần
        searchBar.searchTextField.leftView = UIImageView(image: UIImage(named: "global-search"))
    }
    
    @IBAction func backBtnTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
}
