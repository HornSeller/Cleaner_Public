//
//  LoadingViewController.swift
//  Cleaner
//
//  Created by Macmini on 21/11/2023.
//

import UIKit
import Photos
import CryptoKit
import KDCircularProgress

class LoadingViewController: UIViewController {

    var screenshotsCount = 0
    var screenshotsSize = ""
    var similarCount = 0
    var similarSize = ""
    var duplicatedCount = 0
    var duplicatedSize = ""
    var resizedImage: UIImage?
    var grayImage: UIImage?
    var finalImage: UIImage?
    var grayValue: Double = 0
    var comparisonResult: [[Int]] = []
    var comparisonResults: [[[Int]]] = []
    var similarTotalSize: Int = 0
    var duplicatedTotalSize: Int = 0
    public static var countAndSizeScreenshots: String = ""
    public static var countAndSizeSimilar: String = ""
    public static var countAndSizeDuplicated: String = ""
    public static var similarDataTable: [[ImageAssetPair]] = []
    public static var duplicatedDataTable: [[ImageAssetPair]] = []
    public static var screenshotDataTable: [UIImage] = []
    public static var storage = ""
    @IBOutlet weak var angleLb: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.titleTextAttributes = [
                    NSAttributedString.Key.foregroundColor: UIColor.white,
                    NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)
        ]
        
        let circularProgressWidth: CGFloat = 0.7 * view.frame.width
        let circularProgressFrame = CGRect(x: (view.frame.width - circularProgressWidth) / 2, y: (view.frame.height - circularProgressWidth) / 3, width: circularProgressWidth, height: circularProgressWidth)
        let circularProgress = KDCircularProgress(frame: circularProgressFrame)
        
        let startColor = UIColor(hex: "#F426F4", alpha: 1)
        let endColor = UIColor(hex: "#3445DF", alpha: 1)
        let gradientSize = CGSize(width: circularProgressWidth, height: circularProgressWidth)
        let gradientColor = createGradientColor(startColor: startColor, endColor: endColor, size: gradientSize)
        circularProgress.layer.cornerRadius = circularProgressWidth / 2
        circularProgress.startAngle = 270
        circularProgress.progressThickness = 0.32
        circularProgress.trackThickness = 0.3
        circularProgress.clockwise = false
        circularProgress.gradientRotateSpeed = 2
        circularProgress.roundedCorners = true
        circularProgress.glowAmount = 0.9
        circularProgress.trackColor = UIColor(hex: "#FFFFFF", alpha: 0.1)
        circularProgress.set(colors: gradientColor)
        self.view.addSubview(circularProgress)
        circularProgress.animate(toAngle: 324, duration: 5) { _ in
            
        }
        
        DispatchQueue.global().async {
            self.fetchScreenshotsAlbum()
            LoadingViewController.countAndSizeScreenshots = "\(self.screenshotsCount) photo(s) | \(self.screenshotsSize)"
            
            self.fetchAllPhotos { hashArr, imageAndAssetArr in
                var result: [[ImageAssetPair]] = []
                var currentIndex = 0
                var addedElement: [String] = []
                
                while currentIndex < hashArr.count {
                    let currentString = hashArr[currentIndex]
                    var currentGroup: [String] = [currentString]
                    
                    let currentImageAndAsset = imageAndAssetArr[currentIndex]
                    var currentImageAndAssetGroup: [ImageAssetPair] = [currentImageAndAsset]
                    
                    var nextIndex = currentIndex + 1
                    while nextIndex < hashArr.count {
                        if hashArr[nextIndex] == currentString && !addedElement.contains(currentString) {
                            currentGroup.append(hashArr[nextIndex])
                            currentImageAndAssetGroup.append(imageAndAssetArr[nextIndex])
                        }
                        nextIndex += 1
                    }
                    if currentGroup.count >= 2 {
                        result.append(currentImageAndAssetGroup)
                        addedElement.append(currentString)
                    }
                    
                    currentIndex += 1
                    if currentIndex == hashArr.count {
                        LoadingViewController.duplicatedDataTable = result
                        for i in 0 ..< result.count {
                            for j in 1 ..< result[i].count {
                                self.duplicatedCount += 1
                                self.duplicatedTotalSize += Int(result[i][j].asset.getAssetSize())
                            }
                        }
                    }
                }
            }
            self.similarSize = self.formatSize(Int64(self.similarTotalSize))
            LoadingViewController.countAndSizeSimilar = "\(self.similarCount) photo(s) | \(self.similarSize)"
            self.duplicatedSize = self.formatSize(Int64(self.duplicatedTotalSize))
            LoadingViewController.countAndSizeDuplicated = "\(self.duplicatedCount) photo(s) | \(self.duplicatedSize)"
            DispatchQueue.main.async {
                circularProgress.animate(toAngle: 360, duration: 1, completion: nil)
                //self.performSegue(withIdentifier: "cleanSegue", sender: self)
            }
        }
    }
    
    @IBAction func backBtnTapped(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
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
    
    func fileSize(of image: UIImage?) -> Int {
        guard let imageData = image?.jpegData(compressionQuality: 1.0) else {
            return 0
        }
        
        return imageData.count
    }
    
    func formatSize(_ size: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useGB, .useMB, .useKB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
    
    func fetchScreenshotsAlbum() {
        // Xác định loại album
        let albumType = PHAssetCollectionType.smartAlbum
        let albumSubtype = PHAssetCollectionSubtype.smartAlbumScreenshots

        // Tìm kiếm album dựa trên loại và phụ loại
        let albums = PHAssetCollection.fetchAssetCollections(with: albumType, subtype: albumSubtype, options: nil)

        // Lấy album đầu tiên nếu có
        if let screenshotsAlbum = albums.firstObject {
            print("Album ảnh screenshots: \(screenshotsAlbum.localizedTitle ?? "")")

            // Tiến hành truy cập và xử lý các ảnh trong album
            ScreenshotsViewController.assetArr = fetchPhotos(from: screenshotsAlbum) { tempArr, totalSize, screenshotCount in
                LoadingViewController.screenshotDataTable = tempArr
                self.screenshotsCount = screenshotCount
                self.screenshotsSize = self.formatSize(totalSize)
            }
            
        } else {
            print("Không tìm thấy album ảnh screenshots.")
        }
    }
    
    func fetchPhotos(from album: PHAssetCollection, completion: @escaping ([UIImage], Int64, Int) -> Void) -> [PHAsset] {
        var tempArr: [UIImage] = []
        var assetArr: [PHAsset] = []
        var imageAndAssetArr: [(image: UIImage, asset: PHAsset)] = []
        // Xác định loại ảnh cần truy vấn (ví dụ: chỉ ảnh tĩnh)
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        
        // Sắp xếp các ảnh theo thời gian chụp
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        // Truy vấn các ảnh trong album
        let assets = PHAsset.fetchAssets(in: album, options: options)
        
        // Kích thước mới cho ảnh (giảm độ phân giải)
        let targetSize = CGSize(width: 230, height: 230)
        
        var totalSize: Int64 = 0
        
        // Lặp qua các ảnh và tính tổng dung lượng
        assets.enumerateObjects { (asset, index, stop) in
            let requestOptions = PHImageRequestOptions()
            requestOptions.isSynchronous = true
            assetArr.append(asset)
            // Yêu cầu ảnh với kích thước giảm độ phân giải
            PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: requestOptions, resultHandler: { (image, info) in
                if let image = image {
                    // Thêm ảnh vào mảng allPhotos
                    tempArr.append(image)
                    imageAndAssetArr.append((image, asset))
                    totalSize += asset.getAssetSize()
                }
            })
            if tempArr.count == assets.count {
                completion(tempArr, totalSize, assets.count)
            }
        }
        
        return assetArr
    }
    
    func resizeImage(image: UIImage, newSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    func resizeTo8x8(image: UIImage) -> UIImage? {
        let newSize = CGSize(width: 8, height: 8)
        return resizeImage(image: image, newSize: newSize)
    }
    
    func convertToGrayScale(image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else {
            return nil
        }
        
        let width = cgImage.width
        let height = cgImage.height
        
        let bytesPerPixel = 4 // RGBA
        let bytesPerRow = width * bytesPerPixel
        let bitsPerComponent = 8
        
        let bitmapInfo = CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue
        
        guard let context = CGContext(data: nil,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: bitsPerComponent,
                                      bytesPerRow: bytesPerRow,
                                      space: CGColorSpaceCreateDeviceRGB(),
                                      bitmapInfo: bitmapInfo) else {
            return nil
        }
        
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        
        context.draw(cgImage, in: rect)
        
        guard let data = context.data?.assumingMemoryBound(to: UInt8.self) else {
            return nil
        }
        
        let grayColorSpace = CGColorSpaceCreateDeviceGray()
        guard let grayContext = CGContext(data: nil,
                                          width: width,
                                          height: height,
                                          bitsPerComponent: bitsPerComponent,
                                          bytesPerRow: width,
                                          space: grayColorSpace,
                                          bitmapInfo: 0),
              let grayData = grayContext.data?.assumingMemoryBound(to: UInt8.self) else {
            return nil
        }
        
        for i in 0..<width * height {
            let r = Double(data[i * bytesPerPixel])
            let g = Double(data[i * bytesPerPixel + 1])
            let b = Double(data[i * bytesPerPixel + 2])
            
            let grayValue = UInt8((r + g + b) / 3.0)
            grayData[i] = grayValue
        }
        
        guard let grayImage = grayContext.makeImage() else {
            return nil
        }
        
        return UIImage(cgImage: grayImage)
    }

    func convertTo64Levels(image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else {
            return nil
        }

        let width = cgImage.width
        let height = cgImage.height

        let bytesPerPixel = 1 // Grayscale
        let bytesPerRow = width * bytesPerPixel
        let bitsPerComponent = 8

        let bitmapInfo = CGBitmapInfo.byteOrderDefault.rawValue

        guard let context = CGContext(data: nil,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: bitsPerComponent,
                                      bytesPerRow: bytesPerRow,
                                      space: CGColorSpaceCreateDeviceGray(),
                                      bitmapInfo: bitmapInfo) else {
            return nil
        }

        let rect = CGRect(x: 0, y: 0, width: width, height: height)

        context.draw(cgImage, in: rect)

        guard let data = context.data else {
            return nil
        }

        let pixelBuffer = data.bindMemory(to: UInt8.self, capacity: width * height)

        for i in 0..<width * height {
            let pixelValue = pixelBuffer[i]
            let newPixelValue = UInt8((Double(pixelValue) / 255.0) * 63.0)
            pixelBuffer[i] = newPixelValue
        }

        guard let newGrayImage = context.makeImage() else {
            return nil
        }

        return UIImage(cgImage: newGrayImage)
    }
    
    func averageGrayValue(image: UIImage) -> Double? {
        guard let cgImage = image.cgImage else {
            return nil
        }
        
        let width = cgImage.width
        let height = cgImage.height
        
        guard let data = cgImage.dataProvider?.data else {
            return nil
        }
        
        let pointer = CFDataGetBytePtr(data)
        
        var totalGrayValue: Double = 0.0
        
        for y in 0..<height {
            for x in 0..<width {
                let pixelInfo = (width * y + x) * 1 // Grayscale
                let grayValue = Double(pointer![pixelInfo])
                totalGrayValue += grayValue
            }
        }
        
        let pixelCount = width * height
        let averageGrayValue = totalGrayValue / Double(pixelCount)
        
        return averageGrayValue
    }
    
    func compareGrayValues(image: UIImage, averageValue: Double) -> [[Int]]? {
        guard let cgImage = image.cgImage else {
            return nil
        }
        
        let width = cgImage.width
        let height = cgImage.height
        
        guard let data = cgImage.dataProvider?.data else {
            return nil
        }
        
        let pointer = CFDataGetBytePtr(data)
        
        var result: [[Int]] = Array(repeating: Array(repeating: 0, count: width), count: height)
        
        for y in 0..<height {
            for x in 0..<width {
                let pixelInfo = (width * y + x) * 1 // Grayscale
                let grayValue = Double(pointer![pixelInfo])
                
                if grayValue >= averageValue {
                    result[y][x] = 1
                } else {
                    result[y][x] = 0
                }
            }
        }
        
        return result
    }
    
    func combineComparisonResults(results: [[Int]]) -> UInt64 {
        var combinedResult: UInt64 = 0
        
        for row in results {
            for bit in row {
                combinedResult = (combinedResult << 1) | UInt64(bit)
            }
        }
        
        return combinedResult
    }
    
    func compareArrays(array1: [[Int]], array2: [[Int]]) -> Int {
        guard array1.count == array2.count && !array1.isEmpty && !array2.isEmpty else {
            return 0
        }
        
        let rowCount = array1.count
        let columnCount = array1[0].count
        
        var count = 0
        
        for i in 0..<rowCount {
            for j in 0..<columnCount {
                if array1[i][j] != array2[i][j] {
                    count += 1
                }
            }
        }
        
        return count
    }
    
    func hashImage(image: UIImage) -> String? {
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            return nil
        }
        
        let hash = SHA256.hash(data: imageData)
        let hashString = hash.compactMap { String(format: "%02x", $0) }.joined()
        
        return hashString
    }

    func compareImages(image1: UIImage, image2: UIImage) -> Bool {
        if let hash1 = hashImage(image: image1), let hash2 = hashImage(image: image2) {
            return hash1 == hash2
        }
        return false
    }
    
    func fetchAllPhotos(completion: @escaping ([String], [ImageAssetPair]) -> Void) {
        // Tạo một mảng để lưu trữ tất cả các ảnh
        var hashArr: [String] = []
        var imageAndAssetArr: [ImageAssetPair] = []
        var temp: [ImageAssetPair] = []
        
        // Tạo một đối tượng PHImageManager để truy cập ảnh
        let imageManager = PHImageManager.default()

        // Tạo một đối tượng PHFetchOptions để chỉ định các tùy chọn truy vấn
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

        // Thực hiện truy vấn để lấy tất cả các ảnh
        let allPhotosResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        // Lặp qua tất cả các ảnh và truy cập chúng
        allPhotosResult.enumerateObjects { (asset, index, stop) in
            let requestOptions = PHImageRequestOptions()
            requestOptions.isSynchronous = true
            
            // Lấy ảnh từ PHAsset
            imageManager.requestImage(for: asset, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFill, options: requestOptions, resultHandler: { (image, info) in
                if let image = image {
                    // Thêm ảnh vào mảng allPhotos
                    imageAndAssetArr.append(ImageAssetPair(image: image, asset: asset))
                    hashArr.append(self.hashImage(image: image)!)
                    self.resizedImage = self.resizeTo8x8(image: image)
                    self.grayImage = self.convertToGrayScale(image: self.resizedImage!)
                    self.finalImage = self.convertTo64Levels(image: self.grayImage!)
                    self.grayValue = self.averageGrayValue(image: self.finalImage!)!
                    self.comparisonResult = self.compareGrayValues(image: self.finalImage!, averageValue: self.grayValue)!
                    self.comparisonResults.append(self.comparisonResult)
                    if index > 0 {
                        let value = self.compareArrays(array1: self.comparisonResults[index], array2: self.comparisonResults[index - 1])
                        if value > 0 && value <= 8 {
                            print("giong \(value)")
                            temp = [imageAndAssetArr[index], imageAndAssetArr[index - 1]]
                            LoadingViewController.similarDataTable.append(temp)
                            self.similarTotalSize += Int(asset.getAssetSize())
                            self.similarCount += 1
                        } else {
                            print("khac")
                        }
                    }
                    if self.comparisonResults.count == allPhotosResult.count {
                        completion(hashArr, imageAndAssetArr)
                    }
                }
            })
        }
    }
    
    static func makeSelf() -> LoadingViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let rootViewController: LoadingViewController = storyboard.instantiateViewController(withIdentifier: "LoadingViewController") as! LoadingViewController
        
        return rootViewController
    }

}

extension PHAsset {
    func getAssetSize() -> Int64 {
        var assetSize: Int64 = 0
        let resources = PHAssetResource.assetResources(for: self)
        for resource in resources {
            if let fileSize = resource.value(forKey: "fileSize") as? Int64 {
                assetSize += fileSize
            }
        }
        return assetSize
    }
}

struct ImageAssetPair: Equatable {
    let image: UIImage
    let asset: PHAsset
    
    static func == (lhs: ImageAssetPair, rhs: ImageAssetPair) -> Bool {
        // So sánh các thuộc tính của cặp (UIImage, PHAsset)
        return lhs.image == rhs.image && lhs.asset == rhs.asset
    }
}
