//
//  DuplicatedContactsCollectionViewCell.swift
//  Cleaner
//
//  Created by Macmini on 27/10/2023.
//

import UIKit

class DuplicatedContactsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var firstCaseLb: UILabel!
    @IBOutlet weak var checkboxImageView: UIImageView!
    @IBOutlet weak var numberLb: UILabel!
    @IBOutlet weak var nameLb: UILabel!
    @IBOutlet weak var contactImage: UIImageView!
    @IBOutlet weak var view: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        view.layer.cornerRadius = 12
    }

    override var isSelected: Bool {
        didSet {
            if isSelected {
                checkboxImageView.image = UIImage(named: "Check box 1")
            } else {
                checkboxImageView.image = UIImage(named: "Check box")
            }
        }
    }
}
