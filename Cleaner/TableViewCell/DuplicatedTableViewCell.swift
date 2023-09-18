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
        cell.imageView.image = dataTable[indexPath.row].image
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedImage = dataTable[indexPath.row].image
        let selectedAsset = dataTable[indexPath.row].asset
        let pair = ImageAssetPair(image: selectedImage, asset: selectedAsset)
        DuplicatedViewController.selectedDuplicatedImageAssets.append(pair)
        delegate?.didSelectImage(pair)
    }

    // And when an image is deselected:
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let deselectedImage = dataTable[indexPath.row].image
        let deselectedAsset = dataTable[indexPath.row].asset
        let pairToRemove = ImageAssetPair(image: deselectedImage, asset: deselectedAsset)
        if let index = DuplicatedViewController.selectedDuplicatedImageAssets.firstIndex(where: { $0 == pairToRemove }) {
            DuplicatedViewController.selectedDuplicatedImageAssets.remove(at: index)
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
    var dataTable: [ImageAssetPair] = []
    weak var delegate: ImageSelectionDelegate?
    var isSelectedAll = false
    
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
        collectionView.allowsMultipleSelection = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func selectAllBtnTapped(_ sender: UIButton) {
        mMode = mMode == .view ? .select : .view
        isSelectedAll.toggle()
        
        for indexPath in 1 ..< collectionView.numberOfItems(inSection: 0) {
            let cell = collectionView.cellForItem(at: IndexPath(item: indexPath, section: 0)) as? DuplicatedCollectionViewCell
            cell?.isSelected = isSelectedAll
        }
    }
}
