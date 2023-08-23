//
//  HomeViewController.swift
//  Cleaner
//
//  Created by Macmini on 25/07/2023.
//

import UIKit
import Alamofire
import KDCircularProgress

class HomeViewController: UIViewController, URLSessionDelegate {

    @IBOutlet weak var batteryChartBtn: UIButton!
    @IBOutlet weak var storageBtn: UIButton!
    @IBOutlet weak var speedTestBtn: UIButton!
    @IBOutlet weak var compressBtn: UIButton!
    
    public static var width: CGFloat?
    
    var downloadStartTime: Date!
    var downloadReceivedData: Data = Data()
        
    var uploadStartTime: Date!
    let dataToUpload = Data(count: 10 * 1024 * 1024) // 10MB
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        HomeViewController.width = view.frame.width
        
        batteryChartBtn.layer.cornerRadius = 12
        storageBtn.layer.cornerRadius = 12
        compressBtn.layer.cornerRadius = 12
        speedTestBtn.layer.cornerRadius = 12
        
        let circularProgressWidth: CGFloat = 0.62 * view.frame.width
        let circularProgressFrame = CGRect(x: (view.frame.width - circularProgressWidth) / 2, y: view.frame.height * 3.5 / 12 - circularProgressWidth / 2, width: circularProgressWidth, height: circularProgressWidth)
        let circularProgress = KDCircularProgress(frame: circularProgressFrame)
        
        let startColor = UIColor(red: 244/255, green: 38/255, blue: 244/255, alpha: 1) // Mã màu đầu tiên: #F426F4
        let endColor = UIColor(red: 52/255, green: 69/255, blue: 233/255, alpha: 1) // Mã màu thứ hai: #3445DF
        let gradientSize = CGSize(width: circularProgressWidth, height: circularProgressWidth)
        let gradientColor = createGradientColor(startColor: startColor, endColor: endColor, size: gradientSize)
        
        circularProgress.startAngle = -90
        circularProgress.progressThickness = 0.32
        circularProgress.trackThickness = 0.5
        circularProgress.clockwise = false
        circularProgress.gradientRotateSpeed = 2
        circularProgress.roundedCorners = true
        circularProgress.glowAmount = 0.9
        circularProgress.trackColor = UIColor.clear
        circularProgress.set(colors: gradientColor)
        circularProgress.progress = 0.75
        view.addSubview(circularProgress)

        let imageTest = UIImage(named: "imagetest")
        let imageData = imageTest?.jpegData(compressionQuality: 1.0)
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imageTestURL = documentsURL.appendingPathComponent("imageTest.jpeg")
        do {
            try imageData?.write(to: imageTestURL)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @IBAction func speedTestBtnTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "speedTestSegue", sender: self)
    }
    
    func createGradientColor(startColor: UIColor, endColor: UIColor, size: CGSize) -> UIColor {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(origin: .zero, size: size)
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)

        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return UIColor(patternImage: image!)
    }
}
