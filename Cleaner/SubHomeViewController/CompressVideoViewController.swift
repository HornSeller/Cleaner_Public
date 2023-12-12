//
//  CompressVideoViewController.swift
//  Cleaner
//
//  Created by Mac on 04/10/2023.
//

import UIKit
import AVKit
import Photos

class CompressVideoViewController: UIViewController {

    @IBOutlet weak var compressBtn: UIButton!
    @IBOutlet weak var highCompressBtn: UIButton!
    @IBOutlet weak var lowCompressBtn: UIButton!
    @IBOutlet weak var thumbnail: UIImageView!
    
    var videoURL: URL?
    var videoAssets: PHFetchResult<PHAsset>?
    let activityIndicatorView = UIActivityIndicatorView.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try FileManager.default.removeItem(at: FileManager.default.temporaryDirectory.appendingPathComponent("compressed_video.mp4"))
        } catch {
            print(error.localizedDescription)
        }
        
        lowCompressBtn.layer.cornerRadius = 12
        highCompressBtn.layer.cornerRadius = 12
        compressBtn.layer.cornerRadius = compressBtn.frame.height / 2 + 2
        
        self.navigationController?.navigationBar.titleTextAttributes = [
                    NSAttributedString.Key.foregroundColor: UIColor.white,
                    NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)
        ]
        thumbnail.layer.cornerRadius = 16
        
        thumbnail.image = generateThumbnail(url: videoURL!)
        
        activityIndicatorView.transform = CGAffineTransform(scaleX: 2, y: 2)
        activityIndicatorView.color = .white
    }
    
    @IBAction func lowCompressBtnTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        let buttonStartColor = UIColor(hex: "#F426F4", alpha: 1)
        let buttonEndColor = UIColor(hex: "#3445DF", alpha: 1)
        let gradientColor = createGradientColor(startColor: buttonStartColor, endColor: buttonEndColor, size: CGSize(width: lowCompressBtn.frame.width, height: lowCompressBtn.frame.height))
        
        if highCompressBtn.isSelected {
            highCompressBtn.isSelected = false
            highCompressBtn.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.08)
        }
        
        if sender.isSelected {
            sender.backgroundColor = gradientColor
            compressBtn.isEnabled = true
            compressBtn.backgroundColor = UIColor(hex: "#2361FF", alpha: 1)
            compressBtn.tintColor = UIColor(hex: "#FFFFFF", alpha: 1)
        } else {
            sender.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.08)
            compressBtn.isEnabled = false
            compressBtn.backgroundColor = UIColor(hex: "#97A6AF", alpha: 1)
        }
    }
    
    @IBAction func highCompressBtnTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        let buttonStartColor = UIColor(hex: "#F426F4", alpha: 1)
        let buttonEndColor = UIColor(hex: "#3445DF", alpha: 1)
        let gradientColor = createGradientColor(startColor: buttonStartColor, endColor: buttonEndColor, size: CGSize(width: lowCompressBtn.frame.width, height: lowCompressBtn.frame.height))
        
        if lowCompressBtn.isSelected {
            lowCompressBtn.isSelected = false
            lowCompressBtn.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.08)
        }
        
        if sender.isSelected {
            sender.backgroundColor = gradientColor
            compressBtn.isEnabled = true
            compressBtn.backgroundColor = UIColor(hex: "#2361FF", alpha: 1)
            compressBtn.tintColor = UIColor(hex: "#FFFFFF", alpha: 1)
        } else {
            sender.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.08)
            compressBtn.isEnabled = false
            compressBtn.backgroundColor = UIColor(hex: "#97A6AF", alpha: 1)
        }
    }
    
    @IBAction func compressBtnTapped(_ sender: UIButton) {
        if lowCompressBtn.isSelected {
            compressAndSaveVideoToPhotoLibrary(inputURL: videoURL!, presetName: AVAssetExportPresetHighestQuality)
        } else {
            compressAndSaveVideoToPhotoLibrary(inputURL: videoURL!, presetName: AVAssetExportPresetMediumQuality)
        }
    }
    
    @IBAction func playBtnTapped(_ sender: UIButton) {
        let player = AVPlayer(url: videoURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        present(playerViewController, animated: true) {
            player.play()
        }
    }
    
    @IBAction func backBtnTapped(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    static func makeSelf(url: URL, asset: PHFetchResult<PHAsset>) -> CompressVideoViewController {
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let rootViewController: CompressVideoViewController = storyboard.instantiateViewController(withIdentifier: "CompressVideoViewController") as! CompressVideoViewController
        rootViewController.videoURL = url
        rootViewController.videoAssets = asset
        
        return rootViewController
    }
    
    func generateThumbnail(url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        do {
            let cgImage = try imageGenerator.copyCGImage(at: CMTime(seconds: 0, preferredTimescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            return thumbnail
        } catch {
            print(error.localizedDescription)
            return nil
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
    
    func compressAndSaveVideoToPhotoLibrary(inputURL: URL, presetName: String) {
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.center = CGPoint.init(x: view.frame.size.width / 2, y: view.frame.size.height / 2)
        activityIndicatorView.startAnimating()
        DispatchQueue.main.async {
            self.view.isUserInteractionEnabled = false
            self.navigationItem.leftBarButtonItem?.isEnabled = false
        }
        
        let inputAsset = AVURLAsset(url: inputURL)
        guard let exportSession = AVAssetExportSession(asset: inputAsset, presetName: presetName) else {
            print("Failed to create AVAssetExportSession")
            return
        }
        
        exportSession.outputFileType = AVFileType.mp4
        exportSession.shouldOptimizeForNetworkUse = true
        
        let outputFileName = "compressed_video.mp4"
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(outputFileName)
        print(outputURL)
        exportSession.outputURL = outputURL
        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL)
                }) { success, error in
                    if success {
                        print("Video compressed and saved to photo library successfully!")
                        do {
                            try FileManager.default.removeItem(at: outputURL)
                        } catch {
                            print(error.localizedDescription)
                        }
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "Compress video successfully", message: "Compressed video has been saved to your device", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (_) in
                                self.activityIndicatorView.stopAnimating()
                                self.view.isUserInteractionEnabled = true
                                self.navigationItem.leftBarButtonItem?.isEnabled = true
                                
                                PHPhotoLibrary.shared().performChanges({
                                    PHAssetChangeRequest.deleteAssets(self.videoAssets!)
                                }) { success, error in
                                    if success {
                                        // Photo was successfully removed
                                        DispatchQueue.main.async {
                                            self.navigationController?.popViewController(animated: true)
                                        }
                                    } else {
                                        // Error occurred while removing the photo
                                    }
                                }
                            }))
                            self.present(alert, animated: true)
                        }
                    } else if let error = error {
                        print("Error saving video to photo library: \(error.localizedDescription)")
                    }
                }
            case .failed:
                if let error = exportSession.error {
                    print("Error exporting video: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.activityIndicatorView.stopAnimating()
                        self.view.isUserInteractionEnabled = true
                        self.navigationItem.leftBarButtonItem?.isEnabled = true
                    }
                }
            case .cancelled:
                print("Export session cancelled")
            default:
                break
            }
        }
    }
}
