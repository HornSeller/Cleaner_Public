//
//  DuplicatedContactsTableViewCell.swift
//  Cleaner
//
//  Created by Macmini on 27/10/2023.
//

import UIKit

class DuplicatedContactsTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataCollectionView.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell", for: indexPath) as! DuplicatedContactsCollectionViewCell
        if dataCollectionView[indexPath.row].name.first != " " {
            cell.firstCaseLb.text = dataCollectionView[indexPath.row].name.first?.uppercased()
        } else {
            cell.firstCaseLb.text = dataCollectionView[indexPath.row].name.dropFirst().first?.uppercased()
        }
        cell.nameLb.text = dataCollectionView[indexPath.row].name
        cell.numberLb.text = dataCollectionView[indexPath.row].phoneNumber
        let randomIndex = Int(arc4random_uniform(UInt32(imageNames.count)))
        let randomImageName = imageNames[randomIndex]
        cell.contactImage.image = UIImage(named: randomImageName)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedName = dataCollectionView[indexPath.row].name
        let selectedNumber = dataCollectionView[indexPath.row].phoneNumber
        let contact = ContactInfo(name: selectedName, phoneNumber: selectedNumber)
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
    
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    var dataCollectionView: [ContactInfo] = []
    weak var delegate: ContactSelectionDelegate?
    let imageNames = ["Ellipse 68", "Ellipse 69", "Ellipse 70", "Ellipse 71"]
    
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
