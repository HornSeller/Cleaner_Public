//
//  SettingViewController.swift
//  Cleaner
//
//  Created by Mac on 13/10/2023.
//

import UIKit
import PasscodeKit
import MessageUI
import StoreKit

class SettingViewController: UIViewController, MFMailComposeViewControllerDelegate {

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
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)

        switch result {
        case .cancelled:
            // Xử lý khi người dùng hủy gửi email
            break
        case .saved:
            // Xử lý khi email được lưu như phiên bản nháp
            break
        case .sent:
            // Xử lý khi email được gửi thành công
            break
        case .failed:
            // Xử lý khi gửi email thất bại
            break
        @unknown default:
            break
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
    
    @IBAction func feedbackBtnTapped(_ sender: UIButton) {
        if MFMailComposeViewController.canSendMail() {
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            composeVC.setToRecipients(["youraddress@example.com"])
            composeVC.setSubject("Feedback your app!")
            composeVC.setMessageBody("Dear AppChannel team, \n\n", isHTML: false)
            self.present(composeVC, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: "Error", message: "Please try again later", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    @IBAction func rateBtnTapped(_ sender: UIButton) {
        SKStoreReviewController.requestReview()
    }
    
    @IBAction func shareBtnTapped(_ sender: UIButton) {
        if let name = URL(string: "https://apps.apple.com/vn/app/asphalt-9-legends/id1491129197?mt=12"), !name.absoluteString.isEmpty {
          let objectsToShare = [name]
          let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
          self.present(activityVC, animated: true, completion: nil)
        } else {
          // show alert for not available
            let alert = UIAlertController(title: "Error", message: "Please try again later", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    static func makeSelf() -> SettingViewController {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let rootViewController: SettingViewController = storyboard.instantiateViewController(withIdentifier: "SettingViewController") as! SettingViewController
        
        return rootViewController
    }
}
