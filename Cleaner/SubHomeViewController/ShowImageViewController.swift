//
//  ShowImageViewController.swift
//  Cleaner
//
//  Created by Mac on 29/09/2023.
//

import UIKit

class ShowImageViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    let fileManager = FileManager.default
    var imageV = UIImage()
    var imageN = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = imageV
        imageView.contentMode = .scaleAspectFit
        scrollView.delegate = self
        
        let leftBarButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(leftBarButtonTapped))
        navigationItem.leftBarButtonItem = leftBarButton
        navigationItem.leftBarButtonItem?.tintColor = .white
    }
    
    @objc func leftBarButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    @IBAction func deleteBtnTapped(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Are you really want to delete this Photo?", message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        let okAction = UIAlertAction(title: "OK", style: .destructive, handler: { (_) in
            
            guard let documentURL = self.fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
                return
            }
            
            let photosURL = documentURL.appendingPathComponent("Photos")
            let imageURL = photosURL.appendingPathComponent(self.imageN)
            print(imageURL.path)
            do {
                try self.fileManager.removeItem(atPath: imageURL.path)
                let alert2 = UIAlertController(title: "Delete successfully", message: nil, preferredStyle: .alert)
                alert2.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (_) in
                    self.navigationController?.popViewController(animated: true)
                }))
                self.present(alert2, animated: true)
            } catch let error {
                print(error.localizedDescription)
            }
        })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
    
    static func cellTapped(image: UIImage, imageName: String) -> ShowImageViewController {
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let rootViewController: ShowImageViewController = storyboard.instantiateViewController(withIdentifier: "ShowImageViewController") as! ShowImageViewController
        rootViewController.imageV = image
        rootViewController.imageN = imageName
        
        return rootViewController
    }
}
