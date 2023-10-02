//
//  PrivatePhotosViewController.swift
//  Cleaner
//
//  Created by Macmini on 27/09/2023.
//

import UIKit
import PhotosUI
import Kingfisher

class PrivatePhotosViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        var count = 0
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"

        var imageUrls: [Any] = []
        for result in results {
            
            // Kiểm tra xem đối tượng có phải là ảnh không
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                // Tải ảnh
                result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { (url, error) in
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                    } else if let url = url {
                        imageUrls.append(url)
                        print(url)
                        let imageName = url.lastPathComponent
                        let components = imageName.components(separatedBy: ".")
                        if components.count > 1 {
                            let nameWithoutExtension = components[0]
                            let fileExtension = components.last
                            let name = "\(formatter.string(from: Date()))\(count)_\(nameWithoutExtension).\(fileExtension ?? "jpeg")"
                            let imageUrl = self.albumUrl!.appendingPathComponent(name)
                            do {
                                try self.fileManager.moveItem(at: url, to: imageUrl)
                                self.updatePhotosName()
                                DispatchQueue.main.async {
                                    self.collectionView.reloadData()
                                    self.photoCountLb.text = "\(self.photosName.count) photo(s)"
                                    self.checkPhotoCount()
                                }
                                
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                        count += 1
                        if (count == results.count) {
                            let identifiers = results.compactMap(\.assetIdentifier)
                            let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: nil)
                            PHPhotoLibrary.shared().performChanges({
                                PHAssetChangeRequest.deleteAssets(fetchResult)
                            }) { success, error in
                                if success {
                                    // Photo was successfully removed
                                } else {
                                    // Error occurred while removing the photo
                                }
                            }
                        }
                    }
                }
            }
        }
        dismiss(animated: true)
    }
    
    func updatePhotosName() {
        print(albumUrl ?? "")
        do {
            self.photosName = try fileManager.contentsOfDirectory(atPath: albumUrl!.path)
            self.photosName.sort { (lhs: String, rhs: String) -> Bool in
                return lhs < rhs
            }
            // Lưu danh sách các tệp ảnh vào một mảng
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        photosName.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell", for: indexPath) as! PrivatePhotosCollectionViewCell
        let imageName = photosName[indexPath.row]
        cell.imageView.kf.setImage(with: albumUrl!.appendingPathComponent(imageName), placeholder: UIImage(named: "loading"), options: nil, progressBlock: nil, completionHandler: nil)
        if mMode == .select {
            cell.iconCheckBoxImg.isHidden = false
        } else {
            cell.iconCheckBoxImg.isHidden = true
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let imageName = photosName[indexPath.row]
        let imageURL = albumUrl!.appendingPathComponent(imageName)
        guard let image = UIImage(contentsOfFile: imageURL.path) else {
            return
        }
        switch mMode {
        case .view:
            self.navigationController?.pushViewController(ShowImageViewController.cellTapped(image: image, imageName: imageName), animated: true)
        case .select:
            break
        }
    }
    
    enum Mode {
        case view
        case select
    }
    var mMode: Mode = .view {
        didSet {
            switch mMode {
            case .view:
                collectionView.allowsMultipleSelection = false
                deleteBtn.isHidden = true
                selectBtn.image = UIImage(named: "selectBtn")
                selectBtn.tintColor = .white
            case .select:
                collectionView.allowsMultipleSelection = true
                deleteBtn.isHidden = false
                selectBtn.image = UIImage(named: "deselectBtn")
                //selectBtn.tintColor = .red
            }
        }
    }
    
    @IBOutlet weak var selectBtn: UIBarButtonItem!
    let fileManager = FileManager.default
    var photosName: [String] = []
    var albumUrl: URL?
    
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var photoCountLb: UILabel!
    @IBOutlet weak var labelBackground: UILabel!
    @IBOutlet weak var imageBackground: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        deleteBtn.layer.cornerRadius = 25

        collectionView.register(UINib(nibName: "PrivatePhotosCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "myCell")
        
        let margin: CGFloat = 8
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = margin
        layout.minimumInteritemSpacing = margin
        var sizeCell = (view.frame.size.width - 6 * margin) / 3 - 2
        if UIDevice.current.userInterfaceIdiom == .pad {
            sizeCell = (view.frame.size.width - 5 * margin) / 4 - 2
        }

        layout.itemSize = CGSize(width: sizeCell, height: sizeCell)
        layout.sectionInset = UIEdgeInsets.init(top: 0, left: 16, bottom: 3, right: 16)
        collectionView.collectionViewLayout = layout
        
        // tạo folder Photos tại lần đầu tiên sử dụng app
        guard let documentURL = self.fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let photosURL = documentURL.appendingPathComponent("Photos")
        albumUrl = photosURL
        
        if !self.fileManager.fileExists(atPath: photosURL.path) {
            do {
                try self.fileManager.createDirectory(atPath: photosURL.path, withIntermediateDirectories: true, attributes: nil)
                let documentPath = photosURL.path
                print("Path to pictures directory: \(documentPath)")
            } catch {
                print("Error creating directory: \(error)")
            }
        }
        //
        
        updatePhotosName()
        photoCountLb.text = "\(photosName.count) photo(s)"
        checkPhotoCount()
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                // User has granted access to the photo library
            } else {
                // User has denied or restricted access to the photo library
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.updatePhotosName()
            self.checkPhotoCount()
            self.photoCountLb.text = "\(self.photosName.count) photo(s)"
            self.collectionView.reloadData()
        }
    }
    
    func checkPhotoCount() {
        if photosName.count > 0 {
            imageBackground.isHidden = true
            labelBackground.isHidden = true
        } else {
            imageBackground.isHidden = false
            labelBackground.isHidden = false
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ImageCache.default.clearMemoryCache()
    }
    
    @IBAction func selectBtnTapped(_ sender: UIBarButtonItem) {
        mMode = mMode == .view ? .select : .view
        collectionView.reloadData()
    }
    
    @IBAction func backBtnTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @IBAction func addBtnTapped(_ sender: UIButton) {
        let photoLibrary = PHPhotoLibrary.shared()
        var config = PHPickerConfiguration(photoLibrary: photoLibrary)
        config.selectionLimit = 0
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @IBAction func deleteBtnTapped(_ sender: UIButton) {
        var indexArr: [Int] = []
        if let selectedCell = collectionView.indexPathsForSelectedItems {
            for indexPath in selectedCell.reversed() {
                indexArr.append(indexPath.row)
            }
            
            indexArr.sort(by: >)
            
            if indexArr.count == 0 {
                let alert = UIAlertController(title: "Please choose at least 1 Photo to delete", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                self.present(alert, animated: true)
            }
            
            let alert = UIAlertController(title: "Do you really want to delete \(indexArr.count) Photo(s)?", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (_) in
                for index in indexArr {
                    do {
                        try self.fileManager.removeItem(at: (self.albumUrl!.appendingPathComponent(self.photosName[index])))
                        self.updatePhotosName()
                        DispatchQueue.main.async {
                            self.photoCountLb.text = "\(self.photosName.count) photo(s)"
                            self.checkPhotoCount()
                        }
                        self.collectionView.reloadData()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            self.collectionView.reloadData()
            }))
            alert.addAction(UIAlertAction(title: "No", style: .cancel))
            
            self.present(alert, animated: true)
            
        }
    }
}
