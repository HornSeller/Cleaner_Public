//
//  DuplicatedCollectionViewCell.swift
//  Cleaner
//
//  Created by Macmini on 23/08/2023.
//

import UIKit

class DuplicatedCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imageView.layer.cornerRadius = 10
    }

}
