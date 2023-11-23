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
    
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var dataTable: [[ImageAssetPair]] = []
    var images: [UIImage] = []
    var hashArr: [String] = []
    public static var selectedDuplicatedImageAssets: [ImageAssetPair] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        deleteBtn.layer.cornerRadius = 18
        
        tableView.register(UINib(nibName: "DuplicatedTableViewCell", bundle: .main), forCellReuseIdentifier: "duplicatedCell")

        tableView.rowHeight = 0.2582 * view.frame.height
        
        dataTable = LoadingViewController.duplicatedDataTable
        
        self.navigationController?.navigationBar.titleTextAttributes = [
                    NSAttributedString.Key.foregroundColor: UIColor.white,
                    NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)
        ]
    }
    
    @IBAction func backBtnTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @IBAction func deleteBtnTapped(_ sender: UIButton) {
        var indexPathsToDelete: [IndexPath] = []
        var assetToDelete: [PHAsset] = []
        var sectionToDelete: [Int] = []
        
        if DuplicatedViewController.selectedDuplicatedImageAssets.count == 0 {
            let alert = UIAlertController(title: "Please choose at least 1 Photo to delete", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
            return
        }
        
        for (section, sectionImages) in dataTable.enumerated() {
            var count = 0
            for (row, imageAssetPair) in sectionImages.enumerated() {
                if DuplicatedViewController.selectedDuplicatedImageAssets.contains(imageAssetPair) {
                    // Nếu cặp (UIImage, PHAsset) nằm trong selectedImageAssets,
                    // thêm index path của cell tương ứng vào mảng indexPathsToDelete.
                    count += 1
                    let indexPath = IndexPath(row: row, section: section)
                    if count < sectionImages.count - 1 {
                        indexPathsToDelete.append(indexPath)
                        assetToDelete.append(imageAssetPair.asset)
                    } else {
                        indexPathsToDelete.append(indexPath)
                        assetToDelete.append(imageAssetPair.asset)
                        if !sectionToDelete.contains(section) {
                            sectionToDelete.append(section)
                        }
                    }
                }
            }
        }
        print(sectionToDelete)
        PHPhotoLibrary.shared().performChanges {
            let assetsToDelete = NSArray(array: assetToDelete)
            PHAssetChangeRequest.deleteAssets(assetsToDelete)
        } completionHandler: { (success, error) in
            if success {
                print("Xoá ảnh thành công")
                for indexPath in indexPathsToDelete.reversed() {
                    self.dataTable[indexPath.section].remove(at: indexPath.row)
                    LoadingViewController.duplicatedDataTable[indexPath.section].remove(at: indexPath.row)
                }

                for section in sectionToDelete.reversed() {
                    self.dataTable.remove(at: section)
                    LoadingViewController.duplicatedDataTable.remove(at: section)
                }

                DispatchQueue.main.async {
                    self.tableView.reloadDataAndPerformCustomLogic()
                }
            } else if let error = error {
                print("Lỗi khi xoá ảnh: \(error.localizedDescription)")
            }
        }
    }
    
}
