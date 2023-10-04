//
//  CompressVideoViewController.swift
//  Cleaner
//
//  Created by Mac on 04/10/2023.
//

import UIKit
import AVKit

class CompressVideoViewController: UIViewController {

    @IBOutlet weak var thumbnail: UIImageView!
    
    var imageURL: URL? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.titleTextAttributes = [
                    NSAttributedString.Key.foregroundColor: UIColor.white,
                    NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)
        ]
        thumbnail.layer.cornerRadius = 16
        
        thumbnail.image = generateThumbnail(url: imageURL!)
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
}
