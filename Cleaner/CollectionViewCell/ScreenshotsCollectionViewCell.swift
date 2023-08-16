//
//  ScreenshotsCollectionViewCell.swift
//  Cleaner
//
//  Created by Macmini on 14/08/2023.
//

import UIKit

class ScreenshotsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var checkBoxImageView: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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
