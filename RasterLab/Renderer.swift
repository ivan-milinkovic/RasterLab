import Foundation

let renderer = Renderer()

class Renderer {
    var pixels: [Pixel]
    let w = 200
    let h = 200
    
    init() {
        pixels = [Pixel].init(repeating: Pixel(), count: w*h)
    }
    
    func render() {
        let cnt = box.count
        var i=0; while i<cnt { defer { i += 3 }
            let z = box[i + 2]
            let y = box[i + 1] / z
            let x = box[i] / z
//            print(x, y, z)
            
            let rx = Int(floor(x * Float(w/3) + Float(w/3)))
            let ry = Int(floor(y * Float(h/3) + Float(h/3)))
            
//            print(rx, ry)
            let idx = ry*w + rx
            pixels[idx] = Pixel(white: 1.0)
        }
    }
}
