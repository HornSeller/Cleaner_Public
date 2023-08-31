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
    var dataTable: [[UIImage]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "SimilarTableViewCell", bundle: .main), forCellReuseIdentifier: "similarCell")
        tableView.rowHeight = 0.32 * view.frame.height
        
        dataTable = CleanViewController.similarDataTable
    }
    
    @IBAction func backBtnTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    
}
