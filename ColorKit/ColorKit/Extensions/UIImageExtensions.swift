//
//  UIImageExtensions.swift
//  ColorKit
//
//  Created by Boris Emorine on 5/30/20.
//  Copyright © 2020 BorisEmorine. All rights reserved.
//

import UIKit

extension UIImage {
    
    var resolution: CGSize {
        return CGSize(width: size.width * scale, height: size.height * scale)
    }
    
    func resize(to targetSize: CGSize) -> UIImage {
        guard targetSize != resolution else {
            return self
        }
                
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        let resizedImage = renderer.image { _ in
            self.draw(in: CGRect(origin: CGPoint.zero, size: targetSize))
        }
        
        return resizedImage
    }

    struct NormalizedImageData {
        var bytes: UnsafePointer<UInt8>
        var width: Int
        var height: Int
        var bytesPerRow: Int
    }
    func withNormalizedImageData(_ block: (NormalizedImageData) -> Void) -> Bool {
        guard let orig = cgImage,
              let space = CGColorSpace(name: CGColorSpace.sRGB)
        else { return false }
        let bytesPerRow = orig.width * 4
        let bytesTotal = bytesPerRow * orig.height
        guard let data = malloc(bytesTotal) else {
            return false
        }
        guard let ctx = CGContext(data: data, width: orig.width, height: orig.height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: space, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        else { return false }
        ctx.draw(orig, in: .init(origin: .zero, size: CGSize(width: orig.width, height: orig.height)))
        let dataStruct = NormalizedImageData(bytes: data.assumingMemoryBound(to: UInt8.self), width: orig.width, height: orig.height, bytesPerRow: bytesPerRow)
        block(dataStruct)
        free(data)
        return true
    }
    
}
