//
//  SettingViewController.swift
//  Cleaner
//
//  Created by Mac on 13/10/2023.
//

import UIKit
import PasscodeKit

class SettingViewController: UIViewController {

    @IBOutlet weak var switchBtn: UISwitch!
    @IBOutlet weak var goPremiumBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.titleTextAttributes = [
                    NSAttributedString.Key.foregroundColor: UIColor.white,
                    NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 22)
        ]
        goPremiumBtn.layer.cornerRadius = 16
        
        if PasscodeKit.enabled() {
            switchBtn.isOn = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if PasscodeKit.enabled() {
            switchBtn.isOn = true
        } else {
            switchBtn.isOn = false
        }
    }
    
    @IBAction func backBtnTapped(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        if switchBtn.isOn {
            PasscodeKit.createPasscode(self)
        } else {
            PasscodeKit.removePasscode(self)
        }
    }
    
    @IBAction func changePasscodeBtnTapped(_ sender: UIButton) {
        if !PasscodeKit.enabled() {
            let alert = UIAlertController(title: "PassCode does not exist", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true)
        }
        else {
            PasscodeKit.changePasscode(self)
        }
    }
        
    static func makeSelf() -> SettingViewController {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let rootViewController: SettingViewController = storyboard.instantiateViewController(withIdentifier: "SettingViewController") as! SettingViewController
        
        return rootViewController
    }
}
