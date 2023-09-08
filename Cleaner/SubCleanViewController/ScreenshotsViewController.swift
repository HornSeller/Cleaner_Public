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
        dataCollection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell", for: indexPath) as! ScreenshotsCollectionViewCell
        cell.imageView.image = dataCollection[indexPath.row]
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
    var dataCollection: [UIImage] = []
    var selectedCell: [Int] = []
    public static var assetArr: [PHAsset] = []
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataCollection = CleanViewController.screenshotDataTable
        
        selectBarButton = {
            let barButtonItem = UIBarButtonItem(title: "Select All", style: .plain, target: self, action: #selector(selectBtnTapped(_:)))
            barButtonItem.tintColor = .white
            return barButtonItem
        }()
        navigationItem.rightBarButtonItem = selectBarButton
        
        self.navigationController?.navigationBar.titleTextAttributes = [
                    NSAttributedString.Key.foregroundColor: UIColor.white,
                    NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)
                ]

        collectionView.register(UINib(nibName: "ScreenshotsCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "myCell")
        collectionView.allowsMultipleSelection = true
        
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
        layout.sectionInset = UIEdgeInsets.init(top: margin, left: 16, bottom: margin, right: 16)
        collectionView.collectionViewLayout = layout
        
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
            print(cell?.isSelected ?? "1")
        }
    }
    
    @IBAction func backBtnTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @IBAction func deleteBtnTapped(_ sender: UIButton) {
        deleteImagesFromAssets(assets: ScreenshotsViewController.assetArr)
    }
    
    func deleteImagesFromAssets(assets: [PHAsset]) {
        PHPhotoLibrary.shared().performChanges {
            let assetsToDelete = NSArray(array: assets)
            PHAssetChangeRequest.deleteAssets(assetsToDelete)
        } completionHandler: { (success, error) in
            if success {
                print("Xoá ảnh thành công")
            } else if let error = error {
                print("Lỗi khi xoá ảnh: \(error.localizedDescription)")
            }
        }
    }
}
