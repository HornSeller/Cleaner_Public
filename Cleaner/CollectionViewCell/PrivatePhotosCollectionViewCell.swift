//
//  PrivatePhotosCollectionViewCell.swift
//  Cleaner
//
//  Created by Mac on 28/09/2023.
//

import UIKit

class PrivatePhotosCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imageView.layer.cornerRadius = 10
    }

}
