//
//  DuplicatedCollectionViewCell.swift
//  Cleaner
//
//  Created by Macmini on 23/08/2023.
//

import UIKit

class DuplicatedCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var checkBoxImageView: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imageView.layer.cornerRadius = 10
    }

    override var isSelected: Bool {
        didSet {
            if isSelected {
                checkBoxImageView.image = UIImage(named: "Check box 1")
            } else {
                checkBoxImageView.image = UIImage(named: "Check box")
            }
        }
    }
}
