//
//  FileManagerViewController.swift
//  Cleaner
//
//  Created by Macmini on 25/07/2023.
//

import UIKit

class FileManagerViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var audioBtn: UIButton!
    @IBOutlet weak var documentBtn: UIButton!
    @IBOutlet weak var videoBtn: UIButton!
    @IBOutlet weak var imageBtn: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    var button1: UIButton!
    var button2: UIButton!
    public static var collectionViewWidth: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FileManagerViewController.collectionViewWidth = view.frame.width

        setupRightBarButtonItems()
        
        imageBtn.layer.cornerRadius = 12
        videoBtn.layer.cornerRadius = 12
        documentBtn.layer.cornerRadius = 12
        audioBtn.layer.cornerRadius = 12
        
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).font = UIFont.systemFont(ofSize: 14)
        
        if let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField {
            let placeholderAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor(red: 151/255, green: 166/255, blue: 175/255, alpha: 1), // Màu sắc mong muốn
                .font: UIFont.systemFont(ofSize: 14) // Font chữ mong muốn
            ]
            textFieldInsideSearchBar.attributedPlaceholder = NSAttributedString(string: "Search File", attributes: placeholderAttributes)
        }
        
        searchBar.setImage(UIImage(named: "search-normal"), for: .search, state: .normal)
        
        tableView.register(UINib(nibName: "FileManagerTableViewCell", bundle: .main), forCellReuseIdentifier: "myCell")
        tableView.rowHeight = 0.1878 * view.frame.height
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! FileManagerTableViewCell
        cell.imgView?.image = UIImage(named: "speedtest")
        return cell
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
        searchBar.text = ""
    }
    
    func setupRightBarButtonItems() {
        // Tạo nút 1
        button1 = UIButton(type: .system)
        button1.setTitle("File", for: .normal)
        button1.addTarget(self, action: #selector(button1Tapped), for: .touchUpInside)
        let barButton1 = UIBarButtonItem(customView: button1)

        // Tạo nút 2
        button2 = UIButton(type: .system)
        button2.setTitle("Recent", for: .normal)
        button2.addTarget(self, action: #selector(button2Tapped), for: .touchUpInside)
        let barButton2 = UIBarButtonItem(customView: button2)

        // Đặt các nút vào rightBarButtonItems
        navigationItem.rightBarButtonItems = [barButton1, barButton2]

        // Mặc định nút 1 được chọn
        selectButton(button: button2)
        deselectButton(button: button1)
    }

    @objc func button1Tapped() {
        selectButton(button: button1)
        deselectButton(button: button2)

        // Thực hiện hành động khi Button 1 được chọn
    }

    @objc func button2Tapped() {
        selectButton(button: button2)
        deselectButton(button: button1)

        // Thực hiện hành động khi Button 2 được chọn
    }

    func selectButton(button: UIButton) {
        button.alpha = 1.0
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
    }

    func deselectButton(button: UIButton) {
        button.alpha = 0.5
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
    }
}


