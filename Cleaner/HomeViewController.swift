//
//  HomeViewController.swift
//  Cleaner
//
//  Created by Macmini on 25/07/2023.
//

import UIKit
import Alamofire
import KDCircularProgress

class HomeViewController: UIViewController, URLSessionDelegate {

    @IBOutlet weak var speedTestBtn: UIButton!
    @IBOutlet weak var compressVideoBtn: UIButton!
    @IBOutlet weak var privateMediaBtn: UIButton!
    @IBOutlet weak var privateBrowserBtn: UIButton!
    @IBOutlet weak var percentLb: UILabel!
    @IBOutlet weak var storageLb: UILabel!
    
    public static var width: CGFloat?
    
    var downloadStartTime: Date!
    var downloadReceivedData: Data = Data()
        
    var uploadStartTime: Date!
    let dataToUpload = Data(count: 10 * 1024 * 1024) // 10MB
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        HomeViewController.width = view.frame.width
        
        privateBrowserBtn.layer.cornerRadius = 14
        privateMediaBtn.layer.cornerRadius = 14
        compressVideoBtn.layer.cornerRadius = 14
        speedTestBtn.layer.cornerRadius = 14
        
        let totalDiskSpace = UIDevice.current.totalDiskSpaceInGB
        let usedDiskSpace = UIDevice.current.usedDiskSpaceInGB
        let totalDiskSpace1 = totalDiskSpace.components(separatedBy: " ").first ?? "1"
        let usedDiskSpace1 = usedDiskSpace.components(separatedBy: " ").first ?? "1"

        storageLb.text = "\(usedDiskSpace1)/\(totalDiskSpace1) GB"
        CleanViewController.storage = "\(usedDiskSpace1)/\(totalDiskSpace1) GB"

        let x = (Double(UIDevice.current.usedDiskSpaceInBytes) / Double(UIDevice.current.totalDiskSpaceInBytes)) * 100
        let percent = Int(round(x))
        percentLb.text = "\(percent)%"
        
        let circularProgressWidth: CGFloat = 0.62 * view.frame.width
        let circularProgressFrame = CGRect(x: (view.frame.width - circularProgressWidth) / 2, y: view.frame.height * 3.5 / 12 - circularProgressWidth / 2, width: circularProgressWidth, height: circularProgressWidth)
        let circularProgress = KDCircularProgress(frame: circularProgressFrame)
        
        let startColor = UIColor(red: 244/255, green: 38/255, blue: 244/255, alpha: 1) // Mã màu đầu tiên: #F426F4
        let endColor = UIColor(red: 52/255, green: 69/255, blue: 233/255, alpha: 1) // Mã màu thứ hai: #3445DF
        let gradientSize = CGSize(width: circularProgressWidth, height: circularProgressWidth)
        let gradientColor = createGradientColor(startColor: startColor, endColor: endColor, size: gradientSize)
        
        circularProgress.startAngle = -90
        circularProgress.progressThickness = 0.32
        circularProgress.trackThickness = 0.5
        circularProgress.clockwise = false
        circularProgress.gradientRotateSpeed = 2
        circularProgress.roundedCorners = true
        circularProgress.glowAmount = 0.9
        circularProgress.trackColor = UIColor.clear
        circularProgress.set(colors: gradientColor)
        //circularProgress.progress = Double(percent) / 100.0
        view.addSubview(circularProgress)
        circularProgress.animate(toAngle: Double(percent) / 100.0 * 360, duration: 1, completion: nil)
    }
    
    @IBAction func privatePhotosBtnTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "photosSegue", sender: self)
    }
    
    @IBAction func privateBrowserBtnTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "browserSegue", sender: self)
    }
    
    @IBAction func cleanBtnTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "cleanSegue", sender: self)
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

extension UIDevice {
    func MBFormatter(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = ByteCountFormatter.Units.useMB
        formatter.countStyle = ByteCountFormatter.CountStyle.decimal
        formatter.includesUnit = false
        return formatter.string(fromByteCount: bytes) as String
    }
    
    //MARK: Get String Value
    var totalDiskSpaceInGB:String {
       return ByteCountFormatter.string(fromByteCount: totalDiskSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.decimal)
    }
    
    var freeDiskSpaceInGB:String {
        return ByteCountFormatter.string(fromByteCount: freeDiskSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.decimal)
    }
    
    var usedDiskSpaceInGB:String {
        return ByteCountFormatter.string(fromByteCount: usedDiskSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.decimal)
    }
    
    var totalDiskSpaceInMB:String {
        return MBFormatter(totalDiskSpaceInBytes)
    }
    
    var freeDiskSpaceInMB:String {
        return MBFormatter(freeDiskSpaceInBytes)
    }
    
    var usedDiskSpaceInMB:String {
        return MBFormatter(usedDiskSpaceInBytes)
    }
    
    //MARK: Get raw value
    var totalDiskSpaceInBytes:Int64 {
        guard let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
            let space = (systemAttributes[FileAttributeKey.systemSize] as? NSNumber)?.int64Value else { return 0 }
        return space
    }
    
    var freeDiskSpaceInBytes:Int64 {
        if #available(iOS 11.0, *) {
            if let space = try? URL(fileURLWithPath: NSHomeDirectory() as String).resourceValues(forKeys: [URLResourceKey.volumeAvailableCapacityForImportantUsageKey]).volumeAvailableCapacityForImportantUsage {
                return space ?? 0
            } else {
                return 0
            }
        } else {
            if let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
            let freeSpace = (systemAttributes[FileAttributeKey.systemFreeSize] as? NSNumber)?.int64Value {
                return freeSpace
            } else {
                return 0
            }
        }
    }
    
    var usedDiskSpaceInBytes:Int64 {
       return totalDiskSpaceInBytes - freeDiskSpaceInBytes
    }
}

extension UIColor {
    convenience init(hex: String, alpha: CGFloat) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexString.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex)
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)
        
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
