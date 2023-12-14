//
//  CalendarTableViewCell.swift
//  Cleaner
//
//  Created by Macmini on 14/11/2023.
//

import UIKit

class CalendarTableViewCell: UITableViewCell {

    @IBOutlet weak var checkboxImgView: UIImageView!
    @IBOutlet weak var titleLb: UILabel!
    @IBOutlet weak var dateLb: UILabel!
    @IBOutlet weak var subView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        subView.layer.cornerRadius = 13
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                checkboxImgView.image = UIImage(named: "Check box 1")
            } else {
                checkboxImgView.image = UIImage(named: "Check box")
            }
        }
    }
}
