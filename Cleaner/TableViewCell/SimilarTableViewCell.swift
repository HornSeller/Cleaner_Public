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
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedImage = dataCollection[indexPath.row].image
        let selectedAsset = dataCollection[indexPath.row].asset
        let pair = ImageAssetPair(image: selectedImage, asset: selectedAsset)
        SimilarViewController.selectedImageAssets.append(pair)
        delegate?.didSelectImage(pair)
    }

    // And when an image is deselected:
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let deselectedImage = dataCollection[indexPath.row].image
        let deselectedAsset = dataCollection[indexPath.row].asset
        let pairToRemove = ImageAssetPair(image: deselectedImage, asset: deselectedAsset)
        if let index = SimilarViewController.selectedImageAssets.firstIndex(where: { $0 == pairToRemove }) {
            SimilarViewController.selectedImageAssets.remove(at: index)
        }
        delegate?.didDeselectImage(pairToRemove)
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
    weak var delegate: ImageSelectionDelegate?
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
        mMode = mMode == .view ? .select : .view
        isSelectedAll.toggle()
        
        
        let cell = collectionView.cellForItem(at: IndexPath(item: 1, section: 0)) as? SimilarCollectionViewCell
        cell?.isSelected = isSelectedAll
        
    }
    
}

struct ImageAssetPair: Equatable {
    let image: UIImage
    let asset: PHAsset
    
    static func == (lhs: ImageAssetPair, rhs: ImageAssetPair) -> Bool {
        // So sánh các thuộc tính của cặp (UIImage, PHAsset)
        return lhs.image == rhs.image && lhs.asset == rhs.asset
    }
}

protocol ImageSelectionDelegate: AnyObject {
    func didSelectImage(_ imageAssetPair: ImageAssetPair)
    func didDeselectImage(_ imageAssetPair: ImageAssetPair)
}
