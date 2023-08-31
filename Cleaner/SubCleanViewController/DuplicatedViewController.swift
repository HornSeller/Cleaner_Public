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
    
    @IBOutlet weak var tableView: UITableView!
    var dataTable: [[UIImage]] = []
    var images: [UIImage] = []
    var hashArr: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "DuplicatedTableViewCell", bundle: .main), forCellReuseIdentifier: "duplicatedCell")

        tableView.rowHeight = 0.2582 * view.frame.height
        
        DispatchQueue.main.async {
            self.dataTable = CleanViewController.duplicatedDataTable
        }
    }
    
    @IBAction func backBtnTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
}
