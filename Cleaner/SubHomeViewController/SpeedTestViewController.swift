//
//  SpeedTestViewController.swift
//  Cleaner
//
//  Created by Macmini on 25/07/2023.
//

import UIKit
import Alamofire

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
        
    }
    
    @IBAction func backBtnTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
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

