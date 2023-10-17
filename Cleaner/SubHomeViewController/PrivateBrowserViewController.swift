//
//  PrivateBrowserViewController.swift
//  Cleaner
//
//  Created by Mac on 20/09/2023.
//

import UIKit
import WebKit

class PrivateBrowserViewController: UIViewController, UISearchBarDelegate, WKNavigationDelegate {

    var webView: WKWebView?
    var isWebViewVisible = false
    
    @IBOutlet weak var urlLb: UILabel!
    @IBOutlet weak var forwardBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        urlLb.isUserInteractionEnabled = true

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
        urlLb.addGestureRecognizer(tapGesture)
        
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
        
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
        
        // Khởi tạo WKWebView với configuration
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView?.navigationDelegate = self
        webView?.translatesAutoresizingMaskIntoConstraints = false
        checkBtnEnable()
    }
    
    @objc func labelTapped(sender: UITapGestureRecognizer) {
        let alertController = UIAlertController(title: "Search Something", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Search something"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let submitAction = UIAlertAction(title: "Enter", style: .default) { [weak self, weak alertController] _ in
            if let textField = alertController?.textFields?.first, let inputText = textField.text {
                let request = URLRequest(url: URL(string: "https://google.com/search?q=\(inputText)")!)
                self!.webView!.load(request)
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(submitAction)
        
        present(alertController, animated: true, completion: nil)
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
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !isWebViewVisible {
            // Thêm WKWebView vào view
            if let webView = webView {
                view.addSubview(webView)
                
                // Tạo constraints tùy chỉnh cho kích thước và vị trí
                NSLayoutConstraint.activate([
                    webView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50), // Vị trí top
                    webView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -135), // Vị trí bottom
                    webView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0), // Vị trí left
                    webView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0) // Vị trí right
                ])
                
                // Tạo URL của trang web bạn muốn hiển thị và tải nó lên WKWebView
                let request = URLRequest(url: URL(string: "https://google.com/search?q=\(searchBar.text ?? "")")!)
                webView.load(request)
                searchBar.resignFirstResponder()
                isWebViewVisible = true
            }
            navView.isHidden = false
            backgroundImageView.image = nil
            checkBtnEnable()
            updateURLLabel()
            navigationController?.isNavigationBarHidden = true
        }
    }
    
    @IBAction func closeBtnTapped(_ sender: UIButton) {
        webView?.removeFromSuperview()
        isWebViewVisible = false
        navView.isHidden = true
        backgroundImageView.image = UIImage(named: "Type=Ô dề tối")
        navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func backBtnTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @IBAction func facebookBtnTapped(_ sender: Any) {
        loadWebView(url: "https://fb.com")
    }
    
    @IBAction func twitterBtnTapped(_ sender: Any) {
        loadWebView(url: "https://twitter.com")
    }
    
    @IBAction func googleBtnTapped(_ sender: Any) {
        loadWebView(url: "https://google.com")
    }
    
    @IBAction func linkedinBtnTapped(_ sender: Any) {
        loadWebView(url: "https://linkedin.com")
    }
    
    @IBAction func youtubeBtnTapped(_ sender: Any) {
        loadWebView(url: "https://youtube.com")
    }
    
    @IBAction func instagramBtnTapped(_ sender: Any) {
        loadWebView(url: "https://instagram.com")
    }
    
    @IBAction func pinterestBtnTapped(_ sender: Any) {
        loadWebView(url: "https://pinterest.com")
    }
    
    @IBAction func snapchatBtnTapped(_ sender: Any) {
        loadWebView(url: "https://snapchat.com")
    }
    
    @IBAction func gobackBtnTapped(_ sender: UIButton) {
        webView?.goBack()
        checkBtnEnable()
        updateURLLabel()
    }
    
    @IBAction func goforwardBtnTapped(_ sender: UIButton) {
        webView?.goForward()
        checkBtnEnable()
        updateURLLabel()
    }
    
    func checkBtnEnable() {
        if webView!.canGoBack {
            backBtn.isEnabled = true
        }
        else {
            backBtn.isEnabled = false
        }
        
        if webView!.canGoForward {
            forwardBtn.isEnabled = true
        }
        else {
            forwardBtn.isEnabled = false
        }

    }
    
    func updateURLLabel() {
        if let currentURL = webView?.url {
            // Chuyển đổi đối tượng URL thành chuỗi và gán vào UILabel
            urlLb.text = currentURL.absoluteString
        } else {
            // Xử lý trường hợp không có URL hiện tại
            urlLb.text = "Không có URL hiện tại"
        }
    }
    
    func loadWebView(url: String) {
        if !isWebViewVisible {
            // Thêm WKWebView vào view
            if let webView = webView {
                view.addSubview(webView)
                
                // Tạo constraints tùy chỉnh cho kích thước và vị trí
                NSLayoutConstraint.activate([
                    webView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50), // Vị trí top
                    webView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -135), // Vị trí bottom
                    webView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0), // Vị trí left
                    webView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0) // Vị trí right
                ])
                
                // Tạo URL của trang web bạn muốn hiển thị và tải nó lên WKWebView
                let request = URLRequest(url: URL(string: url)!)
                webView.load(request)

                isWebViewVisible = true
                navView.isHidden = false
                backgroundImageView.image = nil
                checkBtnEnable()
                updateURLLabel()
                navigationController?.isNavigationBarHidden = true
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Trang đã tải xong.")
        checkBtnEnable()
        updateURLLabel()
    }
}
