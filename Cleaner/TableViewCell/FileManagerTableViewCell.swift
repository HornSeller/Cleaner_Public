//
//  FileManagerTableViewCell.swift
//  Cleaner
//
//  Created by Macmini on 01/08/2023.
//

import UIKit
import Photos

class FileManagerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageView4: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var countLb: UILabel!
    @IBOutlet weak var albumNameLb: UILabel!
    var imageArr: [UIImage] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imgView.layer.cornerRadius = 4
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
