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
        if cell.isSelected {
            cell.checkBoxImageView.image = UIImage(named: "Check box 1")
        } else {
            cell.checkBoxImageView.image = UIImage(named: "Check box")
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCell = collectionView.cellForItem(at: indexPath) as! ScreenshotsCollectionViewCell
        selectedCell.checkBoxImageView.image = UIImage(named: "Check box 1")
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let deselectedCell = collectionView.cellForItem(at: indexPath) as! ScreenshotsCollectionViewCell
        deselectedCell.checkBoxImageView.image = UIImage(named: "Check box")
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
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        deleteBtn.layer.cornerRadius = 18
        
        dataCollection = LoadingViewController.screenshotDataTable
        
        print(ScreenshotsViewController.assetArr)
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
        for row in 0 ..< collectionView.numberOfItems(inSection: 0) {
            let cell = collectionView.cellForItem(at: IndexPath(item: row, section: 0)) as? ScreenshotsCollectionViewCell
//            cell?.isSelected = isSelectAllEnabled
            if isSelectAllEnabled {
                collectionView.selectItem(at: IndexPath(row: row, section: 0), animated: true, scrollPosition: UICollectionView.ScrollPosition.left)
            } else {
                collectionView.deselectItem(at: IndexPath(row: row, section: 0), animated: true)
            }
            
            if (cell?.isSelected == true) {
                cell?.checkBoxImageView.image = UIImage(named: "Check box 1")
            } else {
                cell?.checkBoxImageView.image = UIImage(named: "Check box")
            }
        }
        //self.collectionView.reloadData()
    }
    
    @IBAction func backBtnTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @IBAction func deleteBtnTapped(_ sender: UIButton) {
        //deleteImagesFromAssets(assets: ScreenshotsViewController.assetArr)
        var indexArr: [Int] = []
        var deleteImages: [PHAsset] = []
        if let selectedCell = collectionView.indexPathsForSelectedItems {
            for indexPath in selectedCell.reversed() {
                indexArr.append(indexPath.row)
            }
            
            indexArr.sort(by: >)
            print(indexArr)
            
            if indexArr.count == 0 {
                let alert = UIAlertController(title: "Please choose at least 1 Photo to delete", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                self.present(alert, animated: true)
            }
            
            for index in indexArr {
                deleteImages.append(ScreenshotsViewController.assetArr[index])
            }
            PHPhotoLibrary.shared().performChanges {
                let assetsToDelete = NSArray(array: deleteImages)
                PHAssetChangeRequest.deleteAssets(assetsToDelete)
            } completionHandler: { (success, error) in
                if success {
                    for index in indexArr {
                        LoadingViewController.screenshotDataTable.remove(at: index)
                        self.dataCollection.remove(at: index)
                    }
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                    print(self.dataCollection.count)
                } else if let error = error {
                    print("Lỗi khi xoá ảnh: \(error.localizedDescription)")
                }
            }
        }
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
