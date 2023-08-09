//
//  FileManagerViewController.swift
//  Cleaner
//
//  Created by Macmini on 25/07/2023.
//

import UIKit
import Photos

class FileManagerViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var audioBtn: UIButton!
    @IBOutlet weak var documentBtn: UIButton!
    @IBOutlet weak var videoBtn: UIButton!
    @IBOutlet weak var imageBtn: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    var button1: UIButton!
    var button2: UIButton!
    var albumData: [(title: String, images: [UIImage])] = []
    static var count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchAlbumsData()
            
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
        albumData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! FileManagerTableViewCell
        
        let album = albumData[indexPath.row]
        cell.albumNameLb.text = album.title
        cell.imgView?.image = UIImage(named: "speedtest")
        for (index, imageView) in [cell.imageView1, cell.imageView2, cell.imageView3, cell.imageView4].enumerated() {
            if index < album.images.count {
                imageView?.image = album.images[index]
            } else {
                imageView?.image = nil
            }
        }
        return cell
    }
    
    @IBAction func imageBtnTapped(_ sender: UIButton) {
        
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
    
    func fetchAlbumsData() {
        fetchSelfieAlbum() { [weak self] images in
            self?.albumData.append((title: "Selfie", images: images))
            self?.tableView.reloadData()
        }
        fetchScreenshotsAlbum() { [weak self] images in
            self?.albumData.append((title: "Screenshot", images: images))
            self?.tableView.reloadData()
        }
        fetchLivePhotoAlbum() { [weak self] images in
            self?.albumData.append((title: "Live Photo", images: images))
            self?.tableView.reloadData()
        }
        
        fetchPortraitPhotosAlbum() { [weak self] images in
            self?.albumData.append((title: "Portrait", images: images))
            self?.tableView.reloadData()
        }
    }
    
    func fetchScreenshotsAlbum(completion: @escaping ([UIImage]) -> Void) {
        // Xác định loại album
        let albumType = PHAssetCollectionType.smartAlbum
        let albumSubtype = PHAssetCollectionSubtype.smartAlbumScreenshots

        // Tìm kiếm album dựa trên loại và phụ loại
        let albums = PHAssetCollection.fetchAssetCollections(with: albumType, subtype: albumSubtype, options: nil)

        // Lấy album đầu tiên nếu có
        if let screenshotsAlbum = albums.firstObject {
            print("Album ảnh screenshots: \(screenshotsAlbum.localizedTitle ?? "")")

            // Tiến hành truy cập và xử lý các ảnh trong album
            fetchPhotos(from: screenshotsAlbum) { images in
                completion(images)
            }
        } else {
            print("Không tìm thấy album ảnh screenshots.")
        }
    }

    func fetchSelfieAlbum(completion: @escaping ([UIImage]) -> Void) {
        // Xác định loại album
        let albumType = PHAssetCollectionType.smartAlbum
        let albumSubtype = PHAssetCollectionSubtype.smartAlbumSelfPortraits

        // Tìm kiếm album dựa trên loại và phụ loại
        let albums = PHAssetCollection.fetchAssetCollections(with: albumType, subtype: albumSubtype, options: nil)

        // Lấy album đầu tiên nếu có
        if let selfieAlbum = albums.firstObject {
            print("Album ảnh selfie: \(selfieAlbum.localizedTitle ?? "")")

            // Tiến hành truy cập và xử lý các ảnh trong album
            fetchPhotos(from: selfieAlbum) { images in
                completion(images)
            }
        } else {
            print("Không tìm thấy album ảnh selfie.")
        }
    }

    func fetchLivePhotoAlbum(completion: @escaping ([UIImage]) -> Void) {
        // Xác định loại album
        let albumType = PHAssetCollectionType.smartAlbum
        let albumSubtype = PHAssetCollectionSubtype.smartAlbumLivePhotos

        // Tìm kiếm album dựa trên loại và phụ loại
        let albums = PHAssetCollection.fetchAssetCollections(with: albumType, subtype: albumSubtype, options: nil)

        // Lấy album đầu tiên nếu có
        if let liveAlbum = albums.firstObject {
            print("Album ảnh selfie: \(liveAlbum.localizedTitle ?? "")")

            // Tiến hành truy cập và xử lý các ảnh trong album
            fetchPhotos(from: liveAlbum) { images in
                completion(images)
            }
        } else {
            print("Không tìm thấy album ảnh live.")
        }
    }
    
    func fetchPortraitPhotosAlbum(completion: @escaping ([UIImage]) -> Void) {
        // Xác định loại album
        let albumType = PHAssetCollectionType.smartAlbum
        let albumSubtype = PHAssetCollectionSubtype.smartAlbumDepthEffect

        // Tìm kiếm album dựa trên loại và phụ loại
        let albums = PHAssetCollection.fetchAssetCollections(with: albumType, subtype: albumSubtype, options: nil)

        // Lấy album đầu tiên nếu có
        if let portraitAlbum = albums.firstObject {
            print("Album ảnh chân dung: \(portraitAlbum.localizedTitle ?? "")")

            // Tiến hành truy cập và hiển thị ảnh đầu tiên trong album chân dung
            fetchPhotos(from: portraitAlbum) { images in
                completion(images)
            }
        } else {
            print("Không tìm thấy album ảnh chân dung.")
        }
    }
        
    func fetchPhotos(from album: PHAssetCollection, completion: @escaping ([UIImage]) -> Void) {
        // Xác định loại ảnh cần truy vấn (ví dụ: chỉ ảnh tĩnh)
        var tempArr: [UIImage] = []
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)

        // Sắp xếp các ảnh theo thời gian chụp (ảnh mới nhất đến cũ nhất)
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

        // Truy vấn các ảnh trong album
        let assets = PHAsset.fetchAssets(in: album, options: options)

        // Lấy số lượng ảnh tối đa là 4 (ảnh mới nhất)
        let maxImagesToFetch = 4
        
        for index in 0..<min(maxImagesToFetch, assets.count) {
            let asset = assets.object(at: index)
            // Lấy đường dẫn của ảnh
            PHImageManager.default().requestImageData(for: asset, options: nil) { (data, _, _, _) in
                if let imageData = data, let image = UIImage(data: imageData) {
                    // Hiển thị ảnh
                    tempArr.append(image)
                    if tempArr.count == min(maxImagesToFetch, assets.count) {
                        completion(tempArr)
                    }
                }
            }
        }
    }
}
