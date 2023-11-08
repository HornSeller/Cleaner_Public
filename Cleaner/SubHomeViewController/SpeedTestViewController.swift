//
//  SpeedTestViewController.swift
//  Cleaner
//
//  Created by Macmini on 25/07/2023.
//

import UIKit
import Alamofire
import FirebaseStorage
import KDCircularProgress

class SpeedTestViewController: UIViewController {
    
    @IBOutlet weak var startAgainBtn: UIButton!
    @IBOutlet weak var uploadSpeedLb: UILabel!
    @IBOutlet weak var chartImageView: UIImageView!
    @IBOutlet weak var mainLb: UILabel!
    @IBOutlet weak var smallPingLb: UILabel!
    @IBOutlet weak var downloadSpeedLb: UILabel!
    @IBOutlet weak var pingLb: UILabel!
    let circularProgressWidth: CGFloat = 0.55 * HomeViewController.width!
    var circularProgress1 = KDCircularProgress()
    var circularProgressFrame = CGRect()
    var circularProgress2 = KDCircularProgress()
    var trackCircularProgress = KDCircularProgress()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.titleTextAttributes = [
                    NSAttributedString.Key.foregroundColor: UIColor.white,
                    NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)
        ]
        
        circularProgressFrame = CGRect(x: (self.view.frame.width - circularProgressWidth) / 2, y: self.view.frame.height * 0.255, width: circularProgressWidth, height: circularProgressWidth)
        circularProgress1 = KDCircularProgress(frame: circularProgressFrame)
        circularProgress2 = KDCircularProgress(frame: circularProgressFrame)
        trackCircularProgress = KDCircularProgress(frame: circularProgressFrame)
                
        trackCircularProgress.startAngle = -210
        trackCircularProgress.progress = 0.666667
        trackCircularProgress.progressThickness = 0.2
        trackCircularProgress.trackThickness = 0.2
        trackCircularProgress.clockwise = true
        trackCircularProgress.gradientRotateSpeed = 2
        trackCircularProgress.roundedCorners = true
        trackCircularProgress.glowAmount = 0
        trackCircularProgress.trackColor = UIColor.clear
        trackCircularProgress.set(colors: UIColor(hex: "#FFFFFF", alpha: 0.1))
        view.addSubview(trackCircularProgress)
        
        startAgainBtn.layer.cornerRadius = 26
        
        let pinger = try? SwiftyPing(host: "1.1.1.1", configuration: PingConfiguration(interval: 0.5, with: 5), queue: DispatchQueue.global())
        pinger?.observer = { (response) in
            let duration = response.duration
            self.pingLb.text = "\(Int(duration * 1000))"
            self.smallPingLb.text = "\(Int(duration * 1000))ms"
        }
        try? pinger?.startPinging()
        
        testDownloadAndUploadSpeed()
    }
    
    @IBAction func startAgainBtnTapped(_ sender: UIButton) {
        startAgainBtn.isHidden = true
        circularProgress2.removeFromSuperview()
        circularProgress1.progress = -210
        circularProgress2.progress = -210
        chartImageView.image = UIImage(named: "Download")
        mainLb.text = "-"
        downloadSpeedLb.text = "-"
        uploadSpeedLb.text = "-"
        testDownloadAndUploadSpeed()
        
    }
    
    @IBAction func backBtnTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    func testDownloadAndUploadSpeed() {
        testDownloadSpeed() { downloadSpeed in
            let gradientSize = CGSize(width: self.circularProgressWidth, height: self.circularProgressWidth)
            let gradientColor = self.createGradientColor(startColor: UIColor(hex: "#2135E4", alpha: 1), endColor: UIColor(hex: "#DF34CE", alpha: 1), size: gradientSize)
            let gradientColor2 = self.createGradientColor(startColor: UIColor(hex: "#37C556", alpha: 1), endColor: UIColor(hex: "#B3DF34", alpha: 1), size: gradientSize)
            
            self.circularProgress1.startAngle = -210
            self.circularProgress1.progressThickness = 0.2
            self.circularProgress1.trackThickness = 0.2
            self.circularProgress1.clockwise = true
            self.circularProgress1.gradientRotateSpeed = 2
            self.circularProgress1.roundedCorners = true
            self.circularProgress1.glowAmount = 0.9
            self.circularProgress1.trackColor = UIColor.clear
            self.circularProgress1.set(colors: gradientColor)
            
            self.view.addSubview(self.circularProgress1)
            self.circularProgress1.animate(toAngle: (downloadSpeed / 30 * 360), duration: 1, completion: nil)
            
            self.downloadSpeedLb.text = String(format: "%.1f", downloadSpeed)
            self.mainLb.text = String(format: "%.1f", downloadSpeed)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.chartImageView.image = UIImage(named: "Upload")
                self.mainLb.text = "-"
                self.circularProgress1.removeFromSuperview()
                
                self.uploadMedia { uploadTime, fileSize in
                    print("upload time: \(String(describing: uploadTime))\nfile size: \(String(describing: fileSize))")
                    let uploadSpeed = Double(fileSize!) / ( 1024 * 1024) / uploadTime!
                    print("\(uploadSpeed)mbps")
                    
                    self.circularProgress2.startAngle = -210
                    self.circularProgress2.progressThickness = 0.2
                    self.circularProgress2.trackThickness = 0.2
                    self.circularProgress2.clockwise = true
                    self.circularProgress2.gradientRotateSpeed = 2
                    self.circularProgress2.roundedCorners = true
                    self.circularProgress2.glowAmount = 0.9
                    self.circularProgress2.trackColor = UIColor.clear
                    self.circularProgress2.set(colors: gradientColor2)
                    
                    self.view.addSubview(self.circularProgress2)
                    self.circularProgress2.animate(toAngle: (uploadSpeed / 30 * 360), duration: 1, completion: nil)
                    
                    self.uploadSpeedLb.text = String(format: "%.1f", uploadSpeed)
                    self.mainLb.text = String(format: "%.1f", uploadSpeed)
                    self.startAgainBtn.isHidden = false
                }
            }
        }
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
    
    func testDownloadSpeed(completion: @escaping ((Double) -> Void)) {
        let downloadURLString = "https://images.apple.com/v/imac-with-retina/a/images/overview/5k_image.jpg" // Replace with a large file download URL

        let destination: DownloadRequest.Destination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("5k_image.jpg")
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }

        let startTime = CFAbsoluteTimeGetCurrent()

        AF.download(downloadURLString, to: destination).response { response in
            if let error = response.error {
                print("Download Error: \(error)")
            } else {
                let endTime = CFAbsoluteTimeGetCurrent()
                let elapsedTime = endTime - startTime

                // Get file size using FileManager
                let fileManager = FileManager.default
                do {
                    let attributes = try fileManager.attributesOfItem(atPath: response.fileURL?.path ?? "")
                    if let fileSize = attributes[FileAttributeKey.size] as? Double {
                        let downloadSpeed = fileSize / elapsedTime / 1024 / 1024 // in KB/s
                        print("Download Speed: \(downloadSpeed) MB/s")
                        completion(downloadSpeed)
                    }
                } catch {
                    print("Error getting file attributes: \(error)")
                }
            }
        }
    }

    func uploadMedia(completion: @escaping (_ uploadTime: TimeInterval?, _ fileSize: Int?) -> Void) {
        let imageName = UUID().uuidString
        let storageRef = Storage.storage().reference().child(imageName)
        if let uploadData = UIImage(named: "80987170-3497-460F-90DD-1244D9169C17")?.jpegData(compressionQuality: 1) {
            let startTime = Date()
            let metaDataForImage = StorageMetadata()
            metaDataForImage.contentType = "image/jpeg"
            storageRef.putData(uploadData, metadata: metaDataForImage) { (_, error) in
                let endTime = Date()
                if let error = error {
                    print("error: \(error)")
                } else {
                    storageRef.getMetadata { metadata, error in
                        if let fileSize = metadata?.size {
                            let uploadTime = endTime.timeIntervalSince(startTime)
                            print("Thời gian upload: \(uploadTime) giây")
                            completion(uploadTime, Int(fileSize))
                        } else {
                            print("Error getting file size: \(error?.localizedDescription ?? "Unknown error")")
                            completion(nil, nil)
                        }
                    }
                }
            }
        }
    }
}
