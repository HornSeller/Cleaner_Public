//
//  WelcomeViewController.swift
//  Cleaner
//
//  Created by Macmini on 04/12/2023.
//

import UIKit
import SwiftyGif

class WelcomeViewController: UIViewController {

    @IBOutlet var holderView: UIView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    let scrollView = UIScrollView()
    
    var titles: [String]!
    var contents: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titles = ["Smart Cleaner", "Free up Storage", "Speed Test Master"]
        contents = ["Effortlessly scan, identify, and remove duplicates, similar images, and screenshots on your iPhone", "Declutter your schedule by removing outdated events, ensuring a seamless planning experience", "Power up your device by measure, analyze, and optimize your network speed for peak performance"]
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async {
            self.configure()
            self.activityIndicator.isHidden = true
        }
    }
    
    private func configure() {
        scrollView.frame = holderView.bounds
        holderView.addSubview(scrollView)

        for x in 0 ..< 3 {
            let pageView = UIView(frame: CGRect(x: CGFloat(x) * holderView.frame.size.width, y: 0, width: holderView.frame.size.width, height: holderView.frame.size.height))
            scrollView.addSubview(pageView)

            let imageView = UIImageView(frame: CGRect(x: 0, y: 0.1 * holderView.frame.size.height, width: holderView.frame.size.width, height: 0.5 * holderView.frame.size.height))
            imageView.contentMode = .scaleAspectFill
            do {
                let gif = try UIImage(gifName: "onboarding\(x + 1).gif", levelOfIntegrity: 1)
                imageView.setGifImage(gif, loopCount: -1)
            } catch {
                print(error)
            }
            pageView.addSubview(imageView)

            let titleLabel = UILabel(frame: CGRect(x: 0.2977 * holderView.frame.size.width / 2, y: 0.65 * holderView.frame.size.height, width: 0.7023 * holderView.frame.size.width, height: 0.0916 * holderView.frame.size.width))
            titleLabel.textAlignment = .center
            titleLabel.font = UIFont.systemFont(ofSize: isIpad() ? 56 : 32, weight: .semibold)
            titleLabel.textColor = .white
            titleLabel.text = titles[x]
            pageView.addSubview(titleLabel)

            let contentLabel = UILabel(frame: CGRect(x: 0.389313 * holderView.frame.size.width / 2, y: 0.75 * holderView.frame.size.height, width: 0.610687 * holderView.frame.size.width, height: 0.152671 * holderView.frame.size.width))
            contentLabel.textAlignment = .center
            contentLabel.font = UIFont.systemFont(ofSize: isIpad() ? 22 : 14, weight: .medium)
            contentLabel.textColor = UIColor(hex: "#97A6AF", alpha: 1)
            contentLabel.numberOfLines = 0
            contentLabel.text = contents[x]
            pageView.addSubview(contentLabel)

            let button = UIButton(frame: CGRect(x: 0.159033 * holderView.frame.size.width, y: 0.85 * holderView.frame.size.height, width: 0.681934 * holderView.frame.size.width, height: 0.11196 * holderView.frame.size.width))
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = UIColor(hex: "#2361FF", alpha: 1)
            button.setTitle("Continue", for: .normal)
            if x == 2 {
                button.setTitle("Get Started!", for: .normal)
            }
            button.titleLabel?.font = UIFont.systemFont(ofSize: isIpad() ? 30 : 16, weight: .semibold)
            button.layer.cornerRadius = button.frame.size.height / 2
            button.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
            button.tag = x + 1
            pageView.addSubview(button)
        }

        scrollView.contentSize = CGSize(width: holderView.frame.size.width * 3, height: 0)
        scrollView.isPagingEnabled = true
    }

    private func isIpad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    @objc func didTapButton(_ button: UIButton) {
        guard button.tag < 3 else {
            Core.shared.setIsNotNewUser()
            dismiss(animated: true)
            return
        }
        
        scrollView.setContentOffset(CGPoint(x: holderView.frame.size.width * CGFloat(button.tag), y: 0), animated: true)
    }
}

extension UIImage {
    class func gifImageWithData(_ data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }
        
        let frameCount = CGImageSourceGetCount(source)
        var images: [UIImage] = []
        
        for i in 0..<frameCount {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                let image = UIImage(cgImage: cgImage)
                images.append(image)
            }
        }
        
        return UIImage.animatedImage(with: images, duration: 0.0)
    }
}
