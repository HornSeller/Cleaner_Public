//
//  CleanViewController.swift
//  Cleaner
//
//  Created by Mac on 10/08/2023.
//

import UIKit
import Photos

class CleanViewController: UIViewController {


    @IBOutlet weak var countAndSizeDuplicatedLb: UILabel!
    @IBOutlet weak var countAndSizeSimilarLb: UILabel!
    @IBOutlet weak var countAndSizeScreenshotsLb: UILabel!
    @IBOutlet weak var clearBtn: UIButton!
    @IBOutlet weak var duplicatedPhotosBtn: UIButton!
    @IBOutlet weak var similarPhotosBtn: UIButton!
    @IBOutlet weak var screenshotsBtn: UIButton!
    var screenshotsCount = 0
    var screenshotsSize = ""
    var similarCount = 0
    var similarSize = ""
    var duplicatedCount = 0
    var duplicatedSize = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenshotsBtn.layer.cornerRadius = 12
        similarPhotosBtn.layer.cornerRadius = 12
        duplicatedPhotosBtn.layer.cornerRadius = 12
        clearBtn.layer.cornerRadius = 25
        
        fetchScreenshotsAlbum()
        countAndSizeScreenshotsLb.text = "\(screenshotsCount) photo(s) | \(screenshotsSize)"
    }
    
    @IBAction func screenshotsBtnTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "screenshotsSegue", sender: self)
    }
    
    func fetchScreenshotsAlbum() {
        // Xác định loại album
        let albumType = PHAssetCollectionType.smartAlbum
        let albumSubtype = PHAssetCollectionSubtype.smartAlbumScreenshots

        // Tìm kiếm album dựa trên loại và phụ loại
        let albums = PHAssetCollection.fetchAssetCollections(with: albumType, subtype: albumSubtype, options: nil)

        // Lấy album đầu tiên nếu có
        if let screenshotsAlbum = albums.firstObject {
            print("Album ảnh screenshots: \(screenshotsAlbum.localizedTitle ?? "")")

            // Tiến hành truy cập và xử lý các ảnh trong album
            let (screenshotCount, totalSize) = fetchPhotos(from: screenshotsAlbum)
            self.screenshotsCount = screenshotCount
            self.screenshotsSize = formatSize(totalSize)
        } else {
            print("Không tìm thấy album ảnh screenshots.")
        }
    }
    
    func fetchPhotos(from album: PHAssetCollection) -> (Int, Int64) {
        // Xác định loại ảnh cần truy vấn (ví dụ: chỉ ảnh tĩnh)
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        
        // Sắp xếp các ảnh theo thời gian chụp
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        // Truy vấn các ảnh trong album
        let assets = PHAsset.fetchAssets(in: album, options: options)
        
        var totalSize: Int64 = 0
        
        // Lặp qua các ảnh và tính tổng dung lượng
        assets.enumerateObjects { (asset, index, stop) in
            // Tính dung lượng của ảnh và cộng vào tổng
            let assetSize = asset.getAssetSize()
            totalSize += assetSize
            
            // Xử lý ảnh ở đây (ví dụ: lấy thông tin, hiển thị, ...)
            print("Asset \(index + 1): \(asset.localIdentifier), Size: \(assetSize) bytes")
            
        }
        
        let assetCount = assets.count
        
        return (assetCount, totalSize)
    }
    
    func formatSize(_ size: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useGB, .useMB, .useKB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
}

extension PHAsset {
    func getAssetSize() -> Int64 {
        var assetSize: Int64 = 0
        let resources = PHAssetResource.assetResources(for: self)
        for resource in resources {
            if let fileSize = resource.value(forKey: "fileSize") as? Int64 {
                assetSize += fileSize
            }
        }
        return assetSize
    }
}
