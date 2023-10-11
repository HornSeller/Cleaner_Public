//
//  SpeedTestViewController.swift
//  Cleaner
//
//  Created by Macmini on 25/07/2023.
//

import UIKit
import Alamofire

class SpeedTestViewController: UIViewController {
    var uploadSpeed: Double = 0.0
    override func viewDidLoad() {
        super.viewDidLoad()

        testDownloadSpeed()
        testUploadSpeed() { speed in
            print("\(speed)mb")
        }
    }
    
    @IBAction func backBtnTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
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

    func testUploadSpeed(completion: @escaping (Double) -> Void) {
        guard let image = UIImage(named: "imagetest") else {
            print("Image not found")
            completion(0.0)
            return
        }
        
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            print("Error converting image to data")
            completion(0.0)
            return
        }
        
        var request = URLRequest(url: URL(string: "https://freeimage.host/api/1/upload")!)
        request.httpMethod = "POST"
        request.httpBody = imageData
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        URLSession.shared.dataTask(with: request) { (_, response, error) in
            if let error = error {
                print("Upload failed with error: \(error)")
                completion(0.0)
            } else {
                let endTime = CFAbsoluteTimeGetCurrent()
                let elapsedTime = endTime - startTime
                
                if let dataSize = response?.expectedContentLength {
                    // Tính tốc độ upload ở đơn vị Megabits mỗi giây (Mbps)
                    let uploadSpeed = Double(dataSize) * 8 / elapsedTime / 1_000_000
                    self.uploadSpeed = uploadSpeed
                    completion(uploadSpeed)
                } else {
                    print("Invalid or unknown response size")
                    completion(0.0)
                }
            }
        }.resume()
    }

}

