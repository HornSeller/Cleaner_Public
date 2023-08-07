//
//  FileManagerTableViewCell.swift
//  Cleaner
//
//  Created by Macmini on 01/08/2023.
//

import UIKit
import Photos
import Kingfisher

class FileManagerTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell", for: indexPath) as! TableCollectionViewCell
        return cell
    }
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var countLb: UILabel!
    @IBOutlet weak var albumNameLb: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    var cellCount: [Int]?
    var count = 0
    var selfieCount = 0
    var screenshotsCount = 0
    var liveCount = 0
    var portraitCount = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.register(UINib(nibName: "TableCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "myCell")
        
        let margin: CGFloat = 8
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = margin
        layout.minimumInteritemSpacing = margin
        var sizeCell = (FileManagerViewController.collectionViewWidth! * 0.87786 - 3 * margin) / 4
        print(collectionView.frame.width)
//        if UIDevice.current.userInterfaceIdiom == .pad {
//            sizeCell = (FileManagerViewController.collectionViewWidth - 5 * Int(margin)) / 4 - 2
//        }

        layout.itemSize = CGSize(width: sizeCell, height: sizeCell)
        layout.sectionInset = UIEdgeInsets.init(top: margin, left: 0, bottom: margin, right: 0)
        collectionView.collectionViewLayout = layout
        
        fetchSelfieAlbum()
        fetchScreenshotsAlbum()
        fetchLivePhotoAlbum()
        fetchPortraitPhotosAlbum()
        
        cellCount = [selfieCount, liveCount, portraitCount, screenshotsCount]
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func fetchScreenshotsAlbum() {
        // Xác định loại album
        let albumType = PHAssetCollectionType.smartAlbum
        let albumSubtype = PHAssetCollectionSubtype.smartAlbumScreenshots

        // Tìm kiếm album dựa trên loại và phụ loại
        let albums = PHAssetCollection.fetchAssetCollections(with: albumType, subtype: albumSubtype, options: nil)

        // Lấy album đầu tiên nếu có
        if let selfieAlbum = albums.firstObject {
            print("Album ảnh screenshots: \(selfieAlbum.localizedTitle ?? "")")
                
            // Tiến hành truy cập và xử lý các ảnh trong album
            fetchPhotos(from: selfieAlbum)
            screenshotsCount = count
            count = 0
        } else {
            print("Không tìm thấy album ảnh screenshots.")
        }
    }
    
    func fetchSelfieAlbum() {
        // Xác định loại album
        let albumType = PHAssetCollectionType.smartAlbum
        let albumSubtype = PHAssetCollectionSubtype.smartAlbumSelfPortraits

        // Tìm kiếm album dựa trên loại và phụ loại
        let albums = PHAssetCollection.fetchAssetCollections(with: albumType, subtype: albumSubtype, options: nil)

        // Lấy album đầu tiên nếu có
        if let portraitAlbum = albums.firstObject {
            print("Album ảnh selfie: \(portraitAlbum.localizedTitle ?? "")")
            
            // Tiến hành truy cập và xử lý các ảnh trong album
            fetchPhotos(from: portraitAlbum)
            selfieCount = count
            count = 0
        } else {
            print("Không tìm thấy album ảnh selfie.")
        }
    }
    
    func fetchLivePhotoAlbum() {
        // Xác định loại album
        let albumType = PHAssetCollectionType.smartAlbum
        let albumSubtype = PHAssetCollectionSubtype.smartAlbumLivePhotos

        // Tìm kiếm album dựa trên loại và phụ loại
        let albums = PHAssetCollection.fetchAssetCollections(with: albumType, subtype: albumSubtype, options: nil)

        // Lấy album đầu tiên nếu có
        if let liveAlbum = albums.firstObject {
            print("Album ảnh selfie: \(liveAlbum.localizedTitle ?? "")")
            
            // Tiến hành truy cập và xử lý các ảnh trong album
            fetchPhotos(from: liveAlbum)
            liveCount = count
            count = 0
        } else {
            print("Không tìm thấy album ảnh live.")
        }
    }
    
    func fetchPortraitPhotosAlbum() {
            // Xác định loại album
            let albumType = PHAssetCollectionType.smartAlbum
            let albumSubtype = PHAssetCollectionSubtype.smartAlbumDepthEffect

            // Tìm kiếm album dựa trên loại và phụ loại
            let albums = PHAssetCollection.fetchAssetCollections(with: albumType, subtype: albumSubtype, options: nil)

            // Lấy album đầu tiên nếu có
            if let portraitAlbum = albums.firstObject {
                print("Album ảnh chân dung: \(portraitAlbum.localizedTitle ?? "")")

                // Tiến hành truy cập và hiển thị ảnh đầu tiên trong album chân dung
                fetchPhotos(from: portraitAlbum)
                portraitCount = count
                count = 0
            } else {
                print("Không tìm thấy album ảnh chân dung.")
            }
        }
        
        func fetchPhotos(from album: PHAssetCollection) {
            // Xác định loại ảnh cần truy vấn (ví dụ: chỉ ảnh tĩnh)
            let options = PHFetchOptions()
            options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)

            // Sắp xếp các ảnh theo thời gian chụp
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

            // Truy vấn các ảnh trong album
            let assets = PHAsset.fetchAssets(in: album, options: options)

            // Lặp qua các ảnh và xử lý chúng
            assets.enumerateObjects { (asset, index, stop) in
                // Xử lý ảnh ở đây (ví dụ: lấy thông tin, hiển thị, ...)
                print("Asset \(index + 1): \(asset.localIdentifier)")
                self.count += 1
            }
        }
    
}
