//
//  SimilarTableViewCell.swift
//  Cleaner
//
//  Created by Macmini on 21/08/2023.
//

import UIKit
import Photos

class SimilarTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataCollection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell", for: indexPath) as! SimilarCollectionViewCell
        cell.imageView.image = dataCollection[indexPath.row].image
        if isSelected {
            cell.checkBoxImageView.image = UIImage(named: "Check box 1")
        } else {
            cell.checkBoxImageView.image = UIImage(named: "Check box")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCell = collectionView.cellForItem(at: indexPath) as! SimilarCollectionViewCell
        selectedCell.checkBoxImageView.image = UIImage(named: "Check box 1")
        let selectedImage = dataCollection[indexPath.row].image
        let selectedAsset = dataCollection[indexPath.row].asset
        let pair = ImageAssetPair(image: selectedImage, asset: selectedAsset)
        SimilarViewController.selectedSimilarImageAssets.append(pair)
    }

    // And when an image is deselected:
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let deselectedCell = collectionView.cellForItem(at: indexPath) as! SimilarCollectionViewCell
        deselectedCell.checkBoxImageView.image = UIImage(named: "Check box")
        let deselectedImage = dataCollection[indexPath.row].image
        let deselectedAsset = dataCollection[indexPath.row].asset
        let pairToRemove = ImageAssetPair(image: deselectedImage, asset: deselectedAsset)
        if let index = SimilarViewController.selectedSimilarImageAssets.firstIndex(where: { $0 == pairToRemove }) {
            SimilarViewController.selectedSimilarImageAssets.remove(at: index)
        }
    }
    
    enum Mode {
        case view
        case select
    }
    
    var mMode: Mode = .view {
        didSet {
            switch mMode {
            case .view:
                selectAllBtn.setImage(UIImage(named: "Frame 115"), for: .normal)
                
            case .select:
                selectAllBtn.setImage(UIImage(named: "Frame 116"), for: .normal)
                
            }
        }
    }
    
    @IBOutlet weak var selectAllBtn: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var subView: UIView!
    var dataCollection: [ImageAssetPair] = []
    var isSelectedAll = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        subView.layer.cornerRadius = 12
        
        collectionView.register(UINib(nibName: "SimilarCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "myCell")
        
        let margin: CGFloat = 8
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = margin
        layout.minimumInteritemSpacing = margin
        var sizeCell = (HomeViewController.width! * 0.837 - margin) / 2 - 2
//        if UIDevice.current.userInterfaceIdiom == .pad {
//            sizeCell = (view.frame.size.width - 5 * margin) / 4 - 2
//        }

        layout.itemSize = CGSize(width: sizeCell, height: sizeCell)
        layout.sectionInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.collectionViewLayout = layout
        
        collectionView.allowsMultipleSelection = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func selectAllBtnTapped(_ sender: UIButton) {
//        mMode = mMode == .view ? .select : .view
//        isSelectedAll.toggle()
//        
//        let cell = collectionView.cellForItem(at: IndexPath(item: 1, section: 0)) as? SimilarCollectionViewCell
//        cell?.isSelected = isSelectedAll
    }
    
}
