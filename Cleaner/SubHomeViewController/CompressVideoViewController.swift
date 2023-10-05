//
//  CompressVideoViewController.swift
//  Cleaner
//
//  Created by Mac on 04/10/2023.
//

import UIKit
import AVKit

class CompressVideoViewController: UIViewController {

    @IBOutlet weak var compressBtn: UIButton!
    @IBOutlet weak var highCompressBtn: UIButton!
    @IBOutlet weak var lowCompressBtn: UIButton!
    @IBOutlet weak var thumbnail: UIImageView!
    
    var imageURL: URL? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lowCompressBtn.layer.cornerRadius = 12
        highCompressBtn.layer.cornerRadius = 12
        compressBtn.layer.cornerRadius = compressBtn.frame.height / 2 + 2
        
        self.navigationController?.navigationBar.titleTextAttributes = [
                    NSAttributedString.Key.foregroundColor: UIColor.white,
                    NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)
        ]
        thumbnail.layer.cornerRadius = 16
        
        thumbnail.image = generateThumbnail(url: imageURL!)
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
    
    @IBAction func playBtnTapped(_ sender: UIButton) {
        let player = AVPlayer(url: imageURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        present(playerViewController, animated: true) {
            player.play()
        }
    }
    
    @IBAction func backBtnTapped(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    static func makeSelf(url: URL) -> CompressVideoViewController {
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let rootViewController: CompressVideoViewController = storyboard.instantiateViewController(withIdentifier: "CompressVideoViewController") as! CompressVideoViewController
        rootViewController.imageURL = url
        
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
}
