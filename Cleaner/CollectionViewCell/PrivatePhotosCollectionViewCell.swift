//
//  PrivatePhotosCollectionViewCell.swift
//  Cleaner
//
//  Created by Mac on 28/09/2023.
//

import UIKit
import Kingfisher

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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Hủy tải ảnh nếu cell không còn hiển thị nữa
        imageView.kf.cancelDownloadTask()
        imageView.image = nil // Xóa ảnh khỏi imageView
    }
}
