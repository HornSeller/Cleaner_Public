//
//  SimilarCollectionViewCell.swift
//  Cleaner
//
//  Created by Macmini on 21/08/2023.
//

import UIKit

class SimilarCollectionViewCell: UICollectionViewCell {

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
    
    func updateCheckboxImage(selected: Bool) {
        if selected {
            checkBoxImageView.image = UIImage(named: "Check box 1")
        } else {
            checkBoxImageView.image = UIImage(named: "Check box")
        }
    }
}
