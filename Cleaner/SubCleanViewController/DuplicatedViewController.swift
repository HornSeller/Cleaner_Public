//
//  DuplicatedViewController.swift
//  Cleaner
//
//  Created by Macmini on 18/08/2023.
//

import UIKit
import Photos
import CryptoKit

class DuplicatedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataTable.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "duplicatedCell", for: indexPath) as! DuplicatedTableViewCell
        cell.dataTable = dataTable[indexPath.row]
        cell.collectionView.reloadData()
        return cell
    }
    
    @IBOutlet weak var tableView: UITableView!
    var dataTable: [[UIImage]] = []
    var images: [UIImage] = []
    var hashArr: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "DuplicatedTableViewCell", bundle: .main), forCellReuseIdentifier: "duplicatedCell")

        tableView.rowHeight = 0.2582 * view.frame.height
        
        DispatchQueue.main.async {
            self.fetchAllPhotos { hashArr, images in
                self.hashArr = hashArr
                self.images = images
                var result: [[UIImage]] = []
                var currentIndex = 0
                var addedElement: [String] = []
                
                while currentIndex < self.hashArr.count {
                    let currentString = self.hashArr[currentIndex]
                    var currentGroup: [String] = [currentString]
                    
                    let currentImage = self.images[currentIndex]
                    var currentImageGroup: [UIImage] = [currentImage]
                    
                    var nextIndex = currentIndex + 1
                    while nextIndex < self.hashArr.count {
                        if self.hashArr[nextIndex] == currentString && !addedElement.contains(currentString) {
                            currentGroup.append(self.hashArr[nextIndex])
                            currentImageGroup.append(self.images[nextIndex])
                        }
                        nextIndex += 1
                    }
                    if currentGroup.count >= 2 {
                        result.append(currentImageGroup)
                        addedElement.append(currentString)
                    }
                    
                    currentIndex += 1
                    if currentIndex == self.hashArr.count {
                        self.dataTable = result
                        self.tableView.reloadData()
                        print(result)
                    }
                }
                
                print(self.dataTable.count)
            }
        }
    }
    
    @IBAction func backBtnTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    func resizeImage(image: UIImage, newSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func hashImage(image: UIImage) -> String? {
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            return nil
        }
        
        let hash = SHA256.hash(data: imageData)
        let hashString = hash.compactMap { String(format: "%02x", $0) }.joined()
        
        return hashString
    }

    func compareImages(image1: UIImage, image2: UIImage) -> Bool {
        if let hash1 = hashImage(image: image1), let hash2 = hashImage(image: image2) {
            return hash1 == hash2
        }
        return false
    }
    
    func fetchAllPhotos(completion: @escaping ([String], [UIImage]) -> Void) {
        // Tạo một mảng để lưu trữ tất cả các ảnh
        var arr: [String] = []
        var images: [UIImage] = []

        // Tạo một đối tượng PHImageManager để truy cập ảnh
        let imageManager = PHImageManager.default()

        // Tạo một đối tượng PHFetchOptions để chỉ định các tùy chọn truy vấn
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

        // Thực hiện truy vấn để lấy tất cả các ảnh
        let allPhotosResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)

        // Lặp qua tất cả các ảnh và truy cập chúng
        allPhotosResult.enumerateObjects { (asset, index, stop) in
            let requestOptions = PHImageRequestOptions()
            requestOptions.isSynchronous = true

            // Lấy ảnh từ PHAsset
            imageManager.requestImage(for: asset, targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: requestOptions, resultHandler: { (image, info) in
                if let image = image {
                    // Thêm ảnh vào mảng allPhotos
                    images.append(image)
                    arr.append(self.hashImage(image: image)!)
                    if images.count == allPhotosResult.count {
                        completion(arr, images)
                    }
                }
            })
        }
    }
    
}
