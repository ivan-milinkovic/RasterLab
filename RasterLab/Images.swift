import Foundation
import CoreGraphics

struct Pixel {
    var r: UInt8 = 0
    var g: UInt8 = 0
    var b: UInt8 = 0
    var a: UInt8 = 255
    
    init() {
        r = 0
        g = 0
        b = 0
        a = 1
    }
    
    init(r: UInt8 = 0, g: UInt8 = 0, b: UInt8 = 0) {
        self.r = r
        self.g = g
        self.b = b
    }
    
    init(r: UInt8 = 0, g: UInt8 = 0, b: UInt8 = 0, a: UInt8 = 255) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }
    
    init(white: Double) {
        self.init(r: UInt8(white * 255), g: UInt8(white * 255), b: UInt8(white * 255))
    }
}

extension Pixel: ExpressibleByArrayLiteral {
    init(arrayLiteral els: Float...) {
        precondition(els.count>=3)
        r = UInt8(els[0])
        g = UInt8(els[1])
        b = UInt8(els[2])
    }
}

class Images {
    static func cgImageSRGB(_ px: UnsafeRawPointer, w: Int, h: Int, pixelSize: Int) -> CGImage {
        let cgDataProvider = CGDataProvider(data: NSData(bytes: px, length: w * h * pixelSize))!
        let cgImage = CGImage(width: w,
                            height: h,
                            bitsPerComponent: 8,
                            bitsPerPixel: 32,
                            bytesPerRow: w*pixelSize,
                            space: CGColorSpace(name: CGColorSpace.sRGB)!,
                            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.last.rawValue),
                            provider: cgDataProvider,
                            decode: nil,
                            shouldInterpolate: false,
                            intent: CGColorRenderingIntent.defaultIntent)!
        return cgImage
    }
}
