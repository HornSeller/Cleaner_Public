//
//  HomeViewController.swift
//  Cleaner
//
//  Created by Macmini on 25/07/2023.
//

import UIKit
import Alamofire
import MobileCoreServices
import KDCircularProgress
import PhotosUI
import ContactsUI
import EventKit

class HomeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        
        guard let assetIdentifier = results.first?.assetIdentifier else {
            print("Không có video nào được chọn.")
            return
        }

        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: nil)
        if let asset = fetchResult.firstObject {
            PHImageManager.default().requestAVAsset(forVideo: asset, options: nil) { avAsset, _, _ in
                if let urlAsset = avAsset as? AVURLAsset {
                    let videoURL = urlAsset.url
                    print("Đường dẫn của video: \(videoURL)")
                    
                    DispatchQueue.main.async {
                        self.navigationController?.pushViewController(CompressVideoViewController.makeSelf(url: videoURL, asset: fetchResult), animated: true)
                    }
                }
            }
        } else {
            print("Không thể lấy video từ asset identifier.")
        }
    }
    
    @IBOutlet weak var contactAccessNeededBtn: UIButton!
    @IBOutlet weak var calendarAccessNeededBtn: UIButton!
    @IBOutlet weak var contactBtn: UIButton!
    @IBOutlet weak var calendarBtn: UIButton!
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
        
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                // User has granted access to the photo library
            } else {
                // User has denied or restricted access to the photo library
            }
        }
        
        let contactStore = CNContactStore()
        
        // Kiểm tra quyền truy cập danh bạ
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            print("Access contact")
        case .denied, .restricted:
            print("Access denied")
        case .notDetermined:
            // Nếu chưa được xác nhận, yêu cầu quyền truy cập danh bạ từ người dùng
            contactStore.requestAccess(for: .contacts) { (granted, error) in
                if granted {

                } else {
                    print("Access denied")
                }
            }
        }
        
        let eventStore = EKEventStore()
        // Kiểm tra quyền truy cập lịch
        switch EKEventStore.authorizationStatus(for: .event) {
        case .authorized:
            // Đã được cấp quyền, có thể truy cập vào dữ liệu lịch
            print("Access calendar")
        case .denied, .restricted:
            // Người dùng từ chối hoặc bị hạn chế quyền truy cập
            print("Access denied or restricted")
            
        case .notDetermined:
            // Chưa được yêu cầu quyền truy cập, yêu cầu người dùng cấp quyền
            if #available(iOS 17.0, *) {
                eventStore.requestWriteOnlyAccessToEvents { granted, error in
                    if granted {
                        // Đã được cấp quyền, thực hiện lại quá trình truy cập dữ liệu lịch
                    } else {
                        // Quyền truy cập bị từ chối
                        print("Access denied")
                    }
                }
            } else {
                // Fallback on earlier versions
                eventStore.requestAccess(to: .event, completion:
                { (granted: Bool, error: Error?) in
                    if granted {
                        // Đã được cấp quyền, thực hiện lại quá trình truy cập dữ liệu lịch
                    } else {
                        // Quyền truy cập bị từ chối
                        print("Access denied")
                    }
                })
            }
        
        case .fullAccess:
            break
        case .writeOnly:
            break
        @unknown default:
            break
        }
        
        HomeViewController.width = view.frame.width
        
        calendarAccessNeededBtn.layer.cornerRadius = 14
        contactAccessNeededBtn.layer.cornerRadius = 14
        privateBrowserBtn.layer.cornerRadius = 12
        privateMediaBtn.layer.cornerRadius = 12
        compressVideoBtn.layer.cornerRadius = 12
        speedTestBtn.layer.cornerRadius = 12
        calendarBtn.layer.cornerRadius = 12
        contactBtn.layer.cornerRadius = 12
        
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
        
        let startColor = UIColor(hex: "#F426F4", alpha: 1)
        let endColor = UIColor(hex: "#3445DF", alpha: 1)
        let gradientSize = CGSize(width: circularProgressWidth, height: circularProgressWidth)
        let gradientColor = createGradientColor(startColor: startColor, endColor: endColor, size: gradientSize)
        
        circularProgress.startAngle = 270
        circularProgress.progressThickness = 0.32
        circularProgress.trackThickness = 0.3
        circularProgress.clockwise = false
        circularProgress.gradientRotateSpeed = 2
        circularProgress.roundedCorners = true
        circularProgress.glowAmount = 0.9
        circularProgress.trackColor = UIColor(hex: "#FFFFFF", alpha: 0.1)
        circularProgress.set(colors: gradientColor)
        //circularProgress.progress = Double(percent) / 100.0
        view.addSubview(circularProgress)
        circularProgress.animate(toAngle: Double(percent) / 100.0 * 360, duration: 1, completion: nil)
        print("im comeback didload")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        CleanViewController.screenshotDataTable = []
        CleanViewController.similarDataTable = []
        CleanViewController.duplicatedDataTable = []
        print("im comeback didappear")
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func contactAccessNeededBtnTapped(_ sender: UIButton) {
        self.navigationController?.pushViewController(ContactViewController.makeSelf(), animated: true)
    }
    
    @IBAction func calendarAccessNeededBtnTapped(_ sender: UIButton) {
        self.navigationController?.pushViewController(CalendarViewController.makeSelf(), animated: true)
    }
    
    @IBAction func calendarBtnTapped(_ sender: UIButton) {
        self.navigationController?.pushViewController(CalendarViewController.makeSelf(), animated: true)
    }
    
    @IBAction func contactBtnTapped(_ sender: UIButton) {
        self.navigationController?.pushViewController(ContactViewController.makeSelf(), animated: true)
    }
    
    @IBAction func settingBtnTapped(_ sender: UIBarButtonItem) {
        self.navigationController?.pushViewController(SettingViewController.makeSelf(), animated: true)
    }
    
    @IBAction func speedTestBtnTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "speedTestSegue", sender: self)
    }
    
    @IBAction func compressVideoBtnTapped(_ sender: UIButton) {
        let photoLibrary = PHPhotoLibrary.shared()
        var configuration = PHPickerConfiguration(photoLibrary: photoLibrary)
        configuration.filter = .videos
        configuration.selectionLimit = 1
                
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
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
