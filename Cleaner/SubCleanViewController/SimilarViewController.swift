//
//  SimilarViewController.swift
//  Cleaner
//
//  Created by Macmini on 18/08/2023.
//

import UIKit
import Photos

class SimilarViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataTable.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "similarCell", for: indexPath) as! SimilarTableViewCell
        cell.dataCollection = dataTable[indexPath.row]
        return cell
    }

    @IBOutlet weak var tableView: UITableView!
    public static var width: CGFloat?
    var resizedImage: UIImage?
    var grayImage: UIImage?
    var finalImage: UIImage?
    var grayValue: Double = 0
    var comparisonResult: [[Int]] = []
    var comparisonResults: [[[Int]]] = []
    var images: [UIImage] = []
    var dataTable: [[UIImage]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SimilarViewController.width = view.frame.width
        
        tableView.register(UINib(nibName: "SimilarTableViewCell", bundle: .main), forCellReuseIdentifier: "similarCell")
        
        tableView.rowHeight = 0.32 * view.frame.height
        
        var temp: [UIImage] = []
        var value = 0
        fetchAllPhotos { comparisonResults, images in
            self.comparisonResults = comparisonResults
            self.images = images
            for i in 0 ..< self.comparisonResults.count - 1 {
                value = self.compareArrays(array1: self.comparisonResults[i], array2: self.comparisonResults[i + 1])
                if value > 0 && value < 8 {
                    print("giong \(i) \(i + 1)")
                    temp = [images[i], images[i + 1]]
                    self.dataTable.append(temp)
                } else {
                    print("khac \(i) \(i + 1)")
                }
            }
            self.tableView.reloadData()
            print(self.dataTable.count)
        }
    }
    
    @IBAction func backBtnTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
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
    
    func fetchAllPhotos(completion: @escaping ([[[Int]]], [UIImage]) -> Void) {
        // Tạo một mảng để lưu trữ tất cả các ảnh
        var arr: [[[Int]]] = []
        var images: [UIImage] = []

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
            imageManager.requestImage(for: asset, targetSize: CGSize(width: 230, height: 230), contentMode: .aspectFill, options: requestOptions, resultHandler: { (image, info) in
                if let image = image {
                    // Thêm ảnh vào mảng allPhotos
                    images.append(image)
                    self.resizedImage = self.resizeTo8x8(image: self.resizeImage(image: image, targetSize: CGSize(width: 100, height: 100)))
                    self.grayImage = self.convertToGrayScale(image: self.resizedImage!)
                    self.finalImage = self.convertTo64Levels(image: self.grayImage!)
                    self.grayValue = self.averageGrayValue(image: self.finalImage!)!
                    self.comparisonResult = self.compareGrayValues(image: self.finalImage!, averageValue: self.grayValue)!
                    arr.append(self.comparisonResult)
                    if arr.count == allPhotosResult.count {
                        completion(arr, images)
                    }
                }
            })
        }
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        var newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? image
    }
}
