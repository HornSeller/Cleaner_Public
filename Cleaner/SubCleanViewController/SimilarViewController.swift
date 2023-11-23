//
//  SimilarViewController.swift
//  Cleaner
//
//  Created by Macmini on 18/08/2023.
//

import UIKit
import Photos

class SimilarViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataTable.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "similarCell", for: indexPath) as! SimilarTableViewCell
        cell.dataCollection = dataTable[indexPath.row]
        cell.collectionView.reloadData()
        return cell
    }

    @IBOutlet weak var tableView: UITableView!
    
    var comparisonResults: [[[Int]]] = []
    var images: [UIImage] = []
    var dataTable: [[ImageAssetPair]] = []
    @IBOutlet weak var deleteBtn: UIButton!
    public static var selectedSimilarImageAssets: [ImageAssetPair] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        deleteBtn.layer.cornerRadius = 18
        
        tableView.register(UINib(nibName: "SimilarTableViewCell", bundle: .main), forCellReuseIdentifier: "similarCell")
        tableView.rowHeight = 0.32 * view.frame.height
        
        dataTable = LoadingViewController.similarDataTable
        
        self.navigationController?.navigationBar.titleTextAttributes = [
                    NSAttributedString.Key.foregroundColor: UIColor.white,
                    NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)
                ]
    }
    
    @IBAction func backBtnTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @IBAction func deleteBtnTapped(_ sender: Any) {
        var indexPathsToDelete: [IndexPath] = []
        var assetToDelete: [PHAsset] = []
        var sectionToDelete: [Int] = []
        //print(SimilarViewController.selectedImageAssets)
        
        if SimilarViewController.selectedSimilarImageAssets.count == 0 {
            let alert = UIAlertController(title: "Please choose at least 1 Photo to delete", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
            return
        }
        
        for (section, sectionImages) in dataTable.enumerated() {
            for (row, imageAssetPair) in sectionImages.enumerated() {
                if SimilarViewController.selectedSimilarImageAssets.contains(imageAssetPair) {
                    // Nếu cặp (UIImage, PHAsset) nằm trong selectedImageAssets,
                    // thêm index path của cell tương ứng vào mảng indexPathsToDelete.
                    let indexPath = IndexPath(row: row, section: section)
                    indexPathsToDelete.append(indexPath)
                    assetToDelete.append(imageAssetPair.asset)
                    print("\(row) \(section)")
                }
            }
        }
        print("\(indexPathsToDelete) a")
        
        PHPhotoLibrary.shared().performChanges {
            let assetsToDelete = NSArray(array: assetToDelete)
            PHAssetChangeRequest.deleteAssets(assetsToDelete)
        } completionHandler: { (success, error) in
            if success {
                print("Xoá ảnh thành công")
                for indexPath in indexPathsToDelete.reversed() {
                    if sectionToDelete.contains(indexPath.section) {
                        continue
                    }
                    sectionToDelete.append(indexPath.section)
                    self.dataTable.remove(at: indexPath.section)
                    LoadingViewController.similarDataTable.remove(at: indexPath.section)
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

extension UITableView {
    func reloadDataAndPerformCustomLogic() {
        // Thực hiện các tác vụ tùy chỉnh sau khi gọi reloadData()
        
        // Ví dụ: In ra thông báo sau khi reloadData()
        SimilarViewController.selectedSimilarImageAssets = []
        DuplicatedViewController.selectedDuplicatedImageAssets = []
        ContactViewController.selectedDuplicatedContacts = []
        
        // Gọi reloadData() để cập nhật dữ liệu của collectionView
        reloadData()
    }
}
