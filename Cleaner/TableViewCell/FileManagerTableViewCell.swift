//
//  FileManagerTableViewCell.swift
//  Cleaner
//
//  Created by Macmini on 01/08/2023.
//

import UIKit

class FileManagerTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell", for: indexPath) as! TableCollectionViewCell
        return cell
    }
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var countLb: UILabel!
    @IBOutlet weak var albumNameLb: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.register(UINib(nibName: "TableCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "myCell")
        
        let margin: CGFloat = 8
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = margin
        layout.minimumInteritemSpacing = margin
        var sizeCell = (collectionView.frame.width - 3 * margin) / 4
        if UIDevice.current.userInterfaceIdiom == .pad {
            sizeCell = (collectionView.frame.width - 5 * margin) / 4 - 2
        }

        layout.itemSize = CGSize(width: sizeCell, height: sizeCell)
        layout.sectionInset = UIEdgeInsets.init(top: margin, left: 0, bottom: margin, right: 0)
        collectionView.collectionViewLayout = layout
        print(collectionView.frame.width)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
