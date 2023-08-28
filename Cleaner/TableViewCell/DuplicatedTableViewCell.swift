//
//  DuplicatedTableViewCell.swift
//  Cleaner
//
//  Created by Macmini on 23/08/2023.
//

import UIKit

class DuplicatedTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataTable.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "duplicatedCell", for: indexPath) as! DuplicatedCollectionViewCell
        cell.imageView.image = dataTable[indexPath.row]
        return cell
    }
    

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var subView: UIView!
    var dataTable: [UIImage] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        subView.layer.cornerRadius = 12
        
        collectionView.register(UINib(nibName: "DuplicatedCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "duplicatedCell")
        
        let margin: CGFloat = 8
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = margin
        layout.minimumInteritemSpacing = margin
        var sizeCell = (HomeViewController.width! * 0.87786 - 2 * margin) / 2.5 - 2
//        if UIDevice.current.userInterfaceIdiom == .pad {
//            sizeCell = (view.frame.size.width - 5 * margin) / 4 - 2
//        }

        layout.itemSize = CGSize(width: sizeCell, height: sizeCell)
        layout.sectionInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.collectionViewLayout = layout
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
}
