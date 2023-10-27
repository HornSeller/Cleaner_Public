//
//  DuplicatedContactsTableViewCell.swift
//  Cleaner
//
//  Created by Macmini on 27/10/2023.
//

import UIKit

class DuplicatedContactsTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell", for: indexPath) as! DuplicatedContactsCollectionViewCell
        
        return cell
    }
    
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    var dataCollectionView: [ContactInfo] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        subView.layer.cornerRadius = 12
        collectionView.register(UINib(nibName: "DuplicatedContactsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "myCell")
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 14
        layout.minimumInteritemSpacing = 14
        layout.scrollDirection = .horizontal
        var widthSize = (HomeViewController.width! * 0.87786 - 14) / 1.66667 - 2
        layout.itemSize = CGSize(width: widthSize, height: HomeViewController.width! * 0.173)
        layout.sectionInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.collectionViewLayout = layout
        collectionView.allowsMultipleSelection = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
