//
//  ScreenshotsViewController.swift
//  Cleaner
//
//  Created by Macmini on 14/08/2023.
//

import UIKit
import Photos
import Kingfisher

class ScreenshotsViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell", for: indexPath) as! ScreenshotsCollectionViewCell
        cell.imageView.image = data[indexPath.row]
        return cell
    }
    
    enum Mode {
        case view
        case select
    }
    var mMode: Mode = .view {
        didSet {
            switch mMode {
            case .view:
                selectBarButton.title = "Select All"
                
            case .select:
                selectBarButton.title = "Deselect All"
                
            }
        }
    }
    
    var isSelectAllEnabled = false
    var selectBarButton: UIBarButtonItem!
    var data: [UIImage] = []
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectBarButton = {
            let barButtonItem = UIBarButtonItem(title: "Select All", style: .plain, target: self, action: #selector(selectBtnTapped(_:)))
            barButtonItem.tintColor = .white
            return barButtonItem
        }()
        navigationItem.rightBarButtonItem = selectBarButton

        collectionView.register(UINib(nibName: "ScreenshotsCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "myCell")
        collectionView.allowsMultipleSelection = true
        
        let margin: CGFloat = 8
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = margin
        layout.minimumInteritemSpacing = margin
        var sizeCell = (view.frame.size.width - 4 * margin) / 3 - 2
        if UIDevice.current.userInterfaceIdiom == .pad {
            sizeCell = (view.frame.size.width - 5 * margin) / 4 - 2
        }

        layout.itemSize = CGSize(width: sizeCell, height: sizeCell)
        layout.sectionInset = UIEdgeInsets.init(top: margin, left: margin, bottom: margin, right: margin)
        collectionView.collectionViewLayout = layout
        
        collectionViewData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ImageCache.default.clearMemoryCache()
    }
    
    @objc func selectBtnTapped(_ sender: UIBarButtonItem) {
        mMode = mMode == .view ? .select : .view
        isSelectAllEnabled.toggle()
        
        for indexPath in 0 ..< collectionView.numberOfItems(inSection: 0) {
            let cell = collectionView.cellForItem(at: IndexPath(item: indexPath, section: 0)) as? ScreenshotsCollectionViewCell
            cell?.isSelected = isSelectAllEnabled
            print(cell?.isSelected)
        }
    }
    
    @IBAction func backBtnTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    func collectionViewData() {
        fetchScreenshotsAlbum { [weak self] imageURLs in
            self?.data.append(contentsOf: imageURLs)
            self?.collectionView.reloadData()
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
            fetchPhotos(from: screenshotsAlbum) { tempArr in
                completion(tempArr)
            }
        } else {
            print("Không tìm thấy album ảnh screenshots.")
        }
    }
    
    func fetchPhotos(from album: PHAssetCollection, completion: @escaping ([UIImage]) -> Void) {
        var tempArr: [UIImage] = []
        // Xác định loại ảnh cần truy vấn (ví dụ: chỉ ảnh tĩnh)
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        
        // Sắp xếp các ảnh theo thời gian chụp
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        // Truy vấn các ảnh trong album
        let assets = PHAsset.fetchAssets(in: album, options: options)
        
        // Kích thước mới cho ảnh (giảm độ phân giải)
        let targetSize = CGSize(width: 250, height: 250)
        
        // Lặp qua tất cả các ảnh và truy cập chúng
        assets.enumerateObjects { (asset, index, stop) in
            let requestOptions = PHImageRequestOptions()
            requestOptions.isSynchronous = true

            // Yêu cầu ảnh với kích thước giảm độ phân giải
            PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: requestOptions, resultHandler: { (image, info) in
                if let image = image {
                    // Thêm ảnh vào mảng allPhotos
                    tempArr.append(image)
                }
            })
            if tempArr.count == assets.count {
                completion(tempArr)
            }
        }
    }
    
    func cacheImage(path: URL) {
        if let imageData = try? Data(contentsOf: path) {
            if let image = UIImage(data: imageData) {
                ImageCache.default.store(image, forKey: path.path)
            }
        }
    }

}
