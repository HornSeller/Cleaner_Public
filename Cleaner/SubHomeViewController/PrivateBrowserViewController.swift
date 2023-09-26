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
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var navView: UIView!
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
        
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
        
        // Khởi tạo WKWebView với configuration
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView?.navigationDelegate = self
        webView?.translatesAutoresizingMaskIntoConstraints = false
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
            
        }
        
        let closeButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeWebView))
        navigationItem.rightBarButtonItem = closeButton
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
            }
            navView.isHidden = false
            backgroundImageView.image = nil
        }
        
        let closeButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeWebView))
        navigationItem.rightBarButtonItem = closeButton
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Trang đã tải xong.")
    }
    
    @objc func closeWebView() {
        // Đóng WKWebView và trở lại ViewController chính
        webView?.removeFromSuperview()
        isWebViewVisible = false
        navView.isHidden = true
        navigationItem.rightBarButtonItem = nil
        backgroundImageView.image = UIImage(named: "Type=Ô dề tối")
    }
}
