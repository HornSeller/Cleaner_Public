//
//  CleanViewController.swift
//  Cleaner
//
//  Created by Mac on 10/08/2023.
//

import UIKit

class CleanViewController: UIViewController {


    @IBOutlet weak var duplicatedPhotosBtn: UIButton!
    @IBOutlet weak var similarPhotosBtn: UIButton!
    @IBOutlet weak var screenshotsBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        screenshotsBtn.layer.cornerRadius = 12
        similarPhotosBtn.layer.cornerRadius = 12
        duplicatedPhotosBtn.layer.cornerRadius = 12
    }
    

}
