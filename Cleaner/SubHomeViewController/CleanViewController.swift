//
//  CleanViewController.swift
//  Cleaner
//
//  Created by Mac on 10/08/2023.
//

import UIKit
import Photos
import CryptoKit

class CleanViewController: UIViewController {


    @IBOutlet weak var tickImageView: UIImageView!
    @IBOutlet weak var finishLoadingLb: UILabel!
    @IBOutlet weak var storageLb: UILabel!
    @IBOutlet weak var countAndSizeDuplicatedLb: UILabel!
    @IBOutlet weak var countAndSizeSimilarLb: UILabel!
    @IBOutlet weak var countAndSizeScreenshotsLb: UILabel!
    @IBOutlet weak var clearBtn: UIButton!
    @IBOutlet weak var duplicatedPhotosBtn: UIButton!
    @IBOutlet weak var similarPhotosBtn: UIButton!
    @IBOutlet weak var screenshotsBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenshotsBtn.layer.cornerRadius = 12
        similarPhotosBtn.layer.cornerRadius = 12
        duplicatedPhotosBtn.layer.cornerRadius = 12
        
        storageLb.text = LoadingViewController.storage
        self.countAndSizeScreenshotsLb.text = LoadingViewController.countAndSizeScreenshots
        self.countAndSizeSimilarLb.text = LoadingViewController.countAndSizeSimilar
        self.countAndSizeDuplicatedLb.text = LoadingViewController.countAndSizeDuplicated

    }

    @IBAction func screenshotsBtnTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "screenshotsSegue", sender: self)
    }
    
    @IBAction func similarBtnTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "similarSegue", sender: self)
    }
    
    @IBAction func duplicatedBtnTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "duplicatedSegue", sender: self)
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
