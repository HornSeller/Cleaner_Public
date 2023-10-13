//
//  SettingViewController.swift
//  Cleaner
//
//  Created by Mac on 13/10/2023.
//

import UIKit

class SettingViewController: UIViewController {

    @IBOutlet weak var goPremiumBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.titleTextAttributes = [
                    NSAttributedString.Key.foregroundColor: UIColor.white,
                    NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 22)
        ]
        goPremiumBtn.layer.cornerRadius = 16
    }
    
    @IBAction func backBtnTapped(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    static func makeSelf() -> SettingViewController {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let rootViewController: SettingViewController = storyboard.instantiateViewController(withIdentifier: "SettingViewController") as! SettingViewController
        
        return rootViewController
    }
}
