//
//  WelcomeViewController.swift
//  Cleaner
//
//  Created by Macmini on 04/12/2023.
//

import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet var holderView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configure()
    }
    
    private func configure() {
        let scrollView = UIScrollView(frame: holderView.bounds)
        holderView.addSubview(scrollView)
        
        for x in 0 ..< 3 {
            let pageView = UIView(frame: CGRect(x: CGFloat(x) * holderView.frame.size.width, y: 0, width: holderView.frame.size.width, height: holderView.frame.size.height))
            scrollView.addSubview(pageView)
            
            let imageView = UIImageView(frame: CGRect(x: 0.0458 * holderView.frame.size.width / 2, y: 0.14 * holderView.frame.size.width, width: 0.9542 * holderView.frame.size.width, height: 0.9542 * holderView.frame.size.width))
            imageView.image = UIImage(named: "setting")
            imageView.contentMode = .scaleAspectFill
            pageView.addSubview(imageView)
            
            let titleLabel = UILabel(frame: CGRect(x: 0.2977 * holderView.frame.size.width / 2, y: 1.1196 * holderView.frame.size.width, width: 0.7023 * holderView.frame.size.width, height: 0.0916 * holderView.frame.size.width))
            titleLabel.textAlignment = .center
            titleLabel.font = UIFont.systemFont(ofSize: 32, weight: .semibold)
            titleLabel.textColor = .white
            titleLabel.text = "Scan and Create"
            pageView.addSubview(titleLabel)
            
            let contentLabel = UILabel(frame: CGRect(x: 0.389313 * holderView.frame.size.width / 2, y: 1.24682 * holderView.frame.size.width, width: 0.610687 * holderView.frame.size.width, height: 0.152671 * holderView.frame.size.width))
            contentLabel.textAlignment = .center
            contentLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            contentLabel.textColor = UIColor(hex: "#97A6AF", alpha: 1)
            contentLabel.numberOfLines = 0
            contentLabel.text = "Scan and create everything in just one application. The best solution for your whatsapp!"
            pageView.addSubview(contentLabel)
        }
    }
    
}
