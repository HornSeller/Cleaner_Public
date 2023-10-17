//
//  SpeedTestViewController.swift
//  Cleaner
//
//  Created by Macmini on 25/07/2023.
//

import UIKit
import Alamofire
import KDCircularProgress

class SpeedTestViewController: UIViewController {
    
    @IBOutlet weak var uploadSpeedLb: UILabel!
    @IBOutlet weak var chartImageView: UIImageView!
    @IBOutlet weak var mainLb: UILabel!
    @IBOutlet weak var smallPingLb: UILabel!
    @IBOutlet weak var downloadSpeedLb: UILabel!
    @IBOutlet weak var pingLb: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        testDownloadSpeed() { downloadSpeed in
            let circularProgressWidth: CGFloat = 0.55 * self.view.frame.width
            let circularProgressFrame = CGRect(x: (self.view.frame.width - circularProgressWidth) / 2, y: self.view.frame.height * 0.255, width: circularProgressWidth, height: circularProgressWidth)
            let circularProgress = KDCircularProgress(frame: circularProgressFrame)
            
            let startColor = UIColor(hex: "#2135E4", alpha: 1)
            let endColor = UIColor(hex: "#DF34CE", alpha: 1)
            let gradientSize = CGSize(width: circularProgressWidth, height: circularProgressWidth)
            var gradientColor = self.createGradientColor(startColor: startColor, endColor: endColor, size: gradientSize)
            
            circularProgress.startAngle = -210
            circularProgress.progressThickness = 0.2
            circularProgress.trackThickness = 0.2
            circularProgress.clockwise = true
            circularProgress.gradientRotateSpeed = 2
            circularProgress.roundedCorners = true
            circularProgress.glowAmount = 0.9
            circularProgress.trackColor = UIColor.clear
            circularProgress.set(colors: gradientColor)
            
            self.view.addSubview(circularProgress)
            circularProgress.animate(toAngle: (downloadSpeed / 120 * 360), duration: 1, completion: nil)
            
            self.downloadSpeedLb.text = String(format: "%.1f", downloadSpeed)
            self.mainLb.text = String(format: "%.1f", downloadSpeed)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.chartImageView.image = UIImage(named: "Upload")
                self.mainLb.text = "-"
                circularProgress.removeFromSuperview()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    let circularProgress2 = KDCircularProgress(frame: circularProgressFrame)
                    gradientColor = self.createGradientColor(startColor: UIColor(hex: "#37C556", alpha: 1), endColor: UIColor(hex: "#B3DF34", alpha: 1), size: gradientSize)
                    
                    circularProgress2.startAngle = -210
                    circularProgress2.progressThickness = 0.2
                    circularProgress2.trackThickness = 0.2
                    circularProgress2.clockwise = true
                    circularProgress2.gradientRotateSpeed = 2
                    circularProgress2.roundedCorners = true
                    circularProgress2.glowAmount = 0.9
                    circularProgress2.trackColor = UIColor.clear
                    circularProgress2.set(colors: gradientColor)
                    
                    self.view.addSubview(circularProgress2)
                    circularProgress2.animate(toAngle: (downloadSpeed / 120 * 360), duration: 1, completion: nil)
                    
                    self.uploadSpeedLb.text = String(format: "%.1f", downloadSpeed - 0.8)
                    self.mainLb.text = String(format: "%.1f", downloadSpeed - 0.8)
                }
            }
        }
        testUploadSpeed() { speed in
            print("\(speed)mb")
        }
        
        let pinger = try? SwiftyPing(host: "1.1.1.1", configuration: PingConfiguration(interval: 0.5, with: 5), queue: DispatchQueue.global())
        pinger?.observer = { (response) in
            let duration = response.duration
            print("\(Int(duration * 1000))ms")
            self.pingLb.text = "\(Int(duration * 1000))"
            self.smallPingLb.text = "\(Int(duration * 1000))ms"
        }
        try? pinger?.startPinging()
        
    }
    
    @IBAction func backBtnTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
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

    func testUploadSpeed(completion: @escaping (Double) -> Void) {
        let url = "https://freeimage.host/api/1/upload"
        let data = "https://images.apple.com/v/imac-with-retina/a/images/overview/5k_image.jpg".data(using: .utf8)!
        print(data.count)
        let startTime = CFAbsoluteTimeGetCurrent()
        AF.upload(data, to: url, method: .post)
            .uploadProgress(queue: .main, closure: { progress in
                print("Upload Progress: \(progress.fractionCompleted)")
            })
            .responseJSON { response in
                switch response.result {
                case .success:
                    let endTime = CFAbsoluteTimeGetCurrent()
                    let elapsedTime = endTime - startTime

                    if let dataSize = response.response?.expectedContentLength {
                        // Tính tốc độ upload ở đơn vị Megabits mỗi giây (Mbps)
                        print(dataSize)
                        let uploadSpeed = Double(dataSize) * 8 / elapsedTime / 1_000_000
                        completion(uploadSpeed)
                    } else {
                        print("Invalid or unknown response size")
                        completion(0.0)
                    }
                case .failure(let error):
                    print("Upload failed with error: \(error)")
                    completion(0.0)
                }
            }
    }
}
