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
    
    @IBOutlet weak var pingLb: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        testDownloadSpeed()
        testUploadSpeed() { speed in
            print("\(speed)mb")
        }
        
        let pinger = try? SwiftyPing(host: "1.1.1.1", configuration: PingConfiguration(interval: 0.5, with: 5), queue: DispatchQueue.global())
        pinger?.observer = { (response) in
            let duration = response.duration
            print("\(Int(duration * 1000))ms")
            self.pingLb.text = "\(Int(duration * 1000))"
        }
        try? pinger?.startPinging()
        
        let circularProgressWidth: CGFloat = 0.55 * view.frame.width
        let circularProgressFrame = CGRect(x: (view.frame.width - circularProgressWidth) / 2, y: view.frame.height * 0.255, width: circularProgressWidth, height: circularProgressWidth)
        let circularProgress = KDCircularProgress(frame: circularProgressFrame)
        
        let startColor = UIColor(hex: "#2135E4", alpha: 1)
        let endColor = UIColor(hex: "#DF34CE", alpha: 1)
        let gradientSize = CGSize(width: circularProgressWidth, height: circularProgressWidth)
        let gradientColor = createGradientColor(startColor: startColor, endColor: endColor, size: gradientSize)
        
        circularProgress.startAngle = -210
        circularProgress.progressThickness = 0.32
        circularProgress.trackThickness = 0.2
        circularProgress.clockwise = true
        circularProgress.gradientRotateSpeed = 2
        circularProgress.roundedCorners = true
        circularProgress.glowAmount = 0.9
        circularProgress.trackColor = UIColor.clear
        circularProgress.set(colors: gradientColor)
        
        view.addSubview(circularProgress)
        circularProgress.animate(toAngle: 0.6667 * 360, duration: 1, completion: nil)
        
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
    
    func testDownloadSpeed() {
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
