//  UIImage+Extension.swift
//
//  Created by Moritz Philip Recke for Create with Swift on 10 February 2021.
//

import Foundation
import UIKit

extension UIImage {
    
    public func resize(to newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: newSize.width, height: newSize.height), true, 1.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
    
    public func pixelData() -> [UInt8]? {
            let dataSize = size.width * size.height * 4
            var pixelData = [UInt8](repeating: 0, count: Int(dataSize))
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let context = CGContext(data: &pixelData, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: 4 * Int(size.width), space: colorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)
            
            guard let cgImage = self.cgImage else { return nil }
            context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            
            return pixelData
    }
    
    func convertToBuffer() -> CVPixelBuffer? {
       let attributes = [
           kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
           kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue
       ] as CFDictionary
       
       var pixelBuffer: CVPixelBuffer?
       
       let status = CVPixelBufferCreate(
           kCFAllocatorDefault, Int(self.size.width),
           Int(self.size.height),
           kCVPixelFormatType_32ARGB,
           attributes,
           &pixelBuffer)
       
       guard (status == kCVReturnSuccess) else {
           return nil
       }
       
       CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
       
       let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
       let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
       
       let context = CGContext(
           data: pixelData,
           width: Int(self.size.width),
           height: Int(self.size.height),
           bitsPerComponent: 8,
           bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!),
           space: rgbColorSpace,
           bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
       
       context?.translateBy(x: 0, y: self.size.height)
       context?.scaleBy(x: 1.0, y: -1.0)
       
       UIGraphicsPushContext(context!)
       self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
       UIGraphicsPopContext()
       
       CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
       
       return pixelBuffer
   }

}
