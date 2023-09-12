//
//  SimilarViewController.swift
//  Cleaner
//
//  Created by Macmini on 18/08/2023.
//

import UIKit
import Photos

class SimilarViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ImageSelectionDelegate {
    func didSelectImage(_ imageAssetPair: ImageAssetPair) {
        SimilarViewController.selectedImageAssets.append(imageAssetPair)
    }
    
    func didDeselectImage(_ imageAssetPair: ImageAssetPair) {
        if let index = SimilarViewController.selectedImageAssets.firstIndex(where: { $0 == imageAssetPair }) {
            SimilarViewController.selectedImageAssets.remove(at: index)
        }
    }
    
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
    
    var indexPathsToDelete: [IndexPath] = []
    var comparisonResults: [[[Int]]] = []
    var images: [UIImage] = []
    var dataTable: [[ImageAssetPair]] = []
    public static var selectedImageAssets: [ImageAssetPair] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "SimilarTableViewCell", bundle: .main), forCellReuseIdentifier: "similarCell")
        tableView.rowHeight = 0.32 * view.frame.height
        
        dataTable = CleanViewController.similarDataTable
        
        self.navigationController?.navigationBar.titleTextAttributes = [
                    NSAttributedString.Key.foregroundColor: UIColor.white,
                    NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)
                ]
    }
    
    @IBAction func backBtnTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @IBAction func btn(_ sender: Any) {
        //print(SimilarViewController.selectedImageAssets)
        for (section, sectionImages) in dataTable.enumerated() {
            for (row, imageAssetPair) in sectionImages.enumerated() {
                if SimilarViewController.selectedImageAssets.contains(imageAssetPair) {
                    // Nếu cặp (UIImage, PHAsset) nằm trong selectedImageAssets,
                    // thêm index path của cell tương ứng vào mảng indexPathsToDelete.
                    let indexPath = IndexPath(row: row, section: section)
                    indexPathsToDelete.append(indexPath)
                    print("\(row) \(section)")
                }
            }
        }
        
        for indexPath in indexPathsToDelete {
            dataTable.remove(at: indexPath.section)
        }
        print(dataTable.count)
        tableView.beginUpdates()
        tableView.deleteRows(at: indexPathsToDelete, with: .automatic)
        tableView.endUpdates()
    }
}
