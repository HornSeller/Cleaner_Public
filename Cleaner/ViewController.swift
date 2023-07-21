//
//  ViewController.swift
//  Cleaner
//
//  Created by Macmini on 13/07/2023.
//

import UIKit
import Alamofire
import KDCircularProgress

class ViewController: UIViewController, URLSessionDelegate {

    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var speedTestBtn: UIButton!
    @IBOutlet weak var compressBtn: UIButton!
    @IBOutlet weak var storageBtn: UIButton!
    @IBOutlet weak var batteryChartBtn: UIButton!
    
    var downloadStartTime: Date!
    var downloadReceivedData: Data = Data()
        
    var uploadStartTime: Date!
    let dataToUpload = Data(count: 10 * 1024 * 1024) // 10MB
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        batteryChartBtn.layer.cornerRadius = 12
        storageBtn.layer.cornerRadius = 12
        compressBtn.layer.cornerRadius = 12
        speedTestBtn.layer.cornerRadius = 12
        
        let startColor = UIColor(red: 244/255, green: 38/255, blue: 244/255, alpha: 1) // Mã màu đầu tiên: #F426F4
        let endColor = UIColor(red: 52/255, green: 69/255, blue: 233/255, alpha: 1) // Mã màu thứ hai: #3445DF
        let gradientSize = CGSize(width: 200, height: 200)

        let gradientColor = createGradientColor(startColor: startColor, endColor: endColor, size: gradientSize)
        
        let circularProgressWidth: CGFloat = 220
        let circularProgressFrame = CGRect(x: 0, y: 0, width: circularProgressWidth, height: circularProgressWidth)
        let circularProgress = KDCircularProgress(frame: circularProgressFrame)
        circularProgress.startAngle = -90
        circularProgress.progressThickness = 0.35
        circularProgress.trackThickness = 0.5
        circularProgress.clockwise = false
        circularProgress.gradientRotateSpeed = 2
        circularProgress.roundedCorners = true
        circularProgress.glowAmount = 0.9
        circularProgress.trackColor = UIColor.clear
        circularProgress.set(colors: gradientColor)
        circularProgress.center = progressView.center
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

    @IBAction func btn(_ sender: UIButton) {
        print("abc")
    }
    
    @IBAction func speedTestBtnTapped(_ sender: UIButton) {
        performNetworkSpeedTest()
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
        let downloadURLString = "https://github.com/HornSeller/TestUploadFile/archive/refs/heads/main.zip" // Replace with a large file download URL

        let destination: DownloadRequest.Destination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("TestUploadFile-main.zip")
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

    func testUploadSpeed() {
        let uploadURLString = "https://drive.google.com/file/d/1Gz539JHD3PaskU4gJu9h4suHv5QK1ruG/view?usp=drive_link" // Replace with the file upload URL

        // Create a sample file for upload (You can replace this with your own file)
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent("imageTest.jpeg")

        let startTime = CFAbsoluteTimeGetCurrent()

        AF.upload(fileURL, to: uploadURLString).uploadProgress { progress in
            print("Upload Progress: \(progress.fractionCompleted)")
        }.responseString { response in
            if let error = response.error {
                print("Upload Error: \(error)")
            } else {
                let endTime = CFAbsoluteTimeGetCurrent()
                let elapsedTime = endTime - startTime

                // Here you can access the responseString if needed
                if let responseString = response.value {
                    print("Response String: \(responseString)")
                }

                // Get file size using FileManager
                let fileManager = FileManager.default
                do {
                    let attributes = try fileManager.attributesOfItem(atPath: fileURL.path)
                    if let fileSize = attributes[FileAttributeKey.size] as? Double {
                        let uploadSpeed = fileSize / elapsedTime / 1024 / 1024 // in KB/s
                        print("Upload Speed: \(uploadSpeed) MB/s")
                    }
                } catch {
                    print("Error getting file attributes: \(error)")
                }
            }
        }
    }
    
    func performNetworkSpeedTest() {
            let downloadURL = URL(string: "https://github.com/HornSeller/TestUploadFile/archive/refs/heads/main.zip")!
            let uploadURL = URL(string: "https://drive.google.com/file/d/1Gz539JHD3PaskU4gJu9h4suHv5QK1ruG/view?usp=drive_link")!
            
        let downloadConfig = URLSessionConfiguration.default
                let downloadSession = URLSession(configuration: downloadConfig, delegate: self, delegateQueue: nil)
                
                let uploadConfig = URLSessionConfiguration.default
                let uploadSession = URLSession(configuration: uploadConfig, delegate: self, delegateQueue: nil)
                
                // Download
                downloadStartTime = Date()
                let downloadRequest = URLRequest(url: downloadURL)
                let downloadTask = downloadSession.dataTask(with: downloadRequest)
                downloadTask.resume()
                
                // Upload
                uploadStartTime = Date()
                let uploadRequest = URLRequest(url: uploadURL)
                let uploadTask = uploadSession.uploadTask(with: uploadRequest, from: dataToUpload)
                uploadTask.resume()
        }
        
        // URLSessionDataDelegate methods for download
        func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
            downloadReceivedData.append(data)
        }
        
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
            if session.configuration.identifier == "DownloadSession" {
                // Download completed
                let downloadElapsed = Date().timeIntervalSince(downloadStartTime)
                let downloadSpeed = Double(downloadReceivedData.count) / downloadElapsed
                
                print("Tốc độ download: \(downloadSpeed) bytes/s")
            } else if session.configuration.identifier == "UploadSession" {
                // Upload completed
                let uploadElapsed = Date().timeIntervalSince(uploadStartTime)
                let uploadSpeed = Double(dataToUpload.count) / uploadElapsed
                
                print("Tốc độ upload: \(uploadSpeed) bytes/s")
            }
        }

}
