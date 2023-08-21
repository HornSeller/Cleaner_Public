//
//  SimilarCollectionViewCell.swift
//  Cleaner
//
//  Created by Macmini on 21/08/2023.
//

import UIKit

class SimilarCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imageView.layer.cornerRadius = 10
    }

}
