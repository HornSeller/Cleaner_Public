//
//  PrivatePhotosCollectionViewCell.swift
//  Cleaner
//
//  Created by Mac on 28/09/2023.
//

import UIKit

class PrivatePhotosCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var iconCheckBoxImg: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imageView.layer.cornerRadius = 10
    }

    override var isSelected: Bool {
        didSet {
            if isSelected {
                iconCheckBoxImg.image = UIImage(named: "Check box 1")
            }
            else {
                iconCheckBoxImg.image = UIImage(named: "Check box")
            }
        }
    }
}
