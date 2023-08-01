//
//  SpeedTestViewController.swift
//  Cleaner
//
//  Created by Macmini on 25/07/2023.
//

import UIKit
import Alamofire

class SpeedTestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        testDownloadSpeed()
        testUploadSpeed()
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

}
