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
//        let t0 = Date()
//        renderBox()
        renderTriangle()
//        renderLine()
//        let dt = Date().timeIntervalSince(t0)*1_000_000
//        print("\(dt)us")
    }
    
    func renderLine() {
        let v1: Vec3 = [0,0,0]
        let v2: Vec3 = [100,100,0]
        
        let idx1 = Int(v1.y)*w + Int(v1.x)
        let idx2 = Int(v2.y)*w + Int(v2.x)
        pixels[idx1] = Pixel(white: 1.0)
        pixels[idx2] = Pixel(white: 1.0)
        
        let dx = v2.x - v1.x
        let dy = v2.y - v1.y
        let dist = sqrt(dx*dx + dy*dy)
        
        for step in stride(from: 0.0, through: dist, by: 1.0) {
            let f = step/dist
            let x_lerp = v1.x + f * dx
            let y_lerp = v1.y + f * dy
            
            let idx = Int(y_lerp)*w + Int(x_lerp)
            pixels[idx] = Pixel(white: 0.8)
        }
    }
    
    func renderTriangle() {
        let t = Geo.triangle
        let tc = Geo.triangleColors
        let wf = Float(w)
        let hf = Float(h)
        
        // project triangle
        var tp = [Vec3]() // triangle projected
        tp.reserveCapacity(t.count)
        for v in t {
            let z = v.z
            let y = v.y / z
            let x = v.x / z
            
            let xp = x*wf*0.8 + wf*0.1
            let yp = y*hf*0.8 + hf*0.1
            
            let vp = Vec3(xp, yp, z)
            tp.append(vp)
        }
        
        // fill triangle
        
        let area = abs(edgeFunction(tp[0], tp[1], tp[2]))
        
        //  bounding box
        let xmin = Int(min(tp[0].x, min(tp[1].x, tp[2].x)))
        let ymin = Int(min(tp[0].y, min(tp[1].y, tp[2].y)))
        let xmax = Int(max(tp[0].x, max(tp[1].x, tp[2].x)))
        let ymax = Int(max(tp[0].y, max(tp[1].y, tp[2].y)))
        for ix in xmin...xmax {
            for iy in ymin...ymax {
                // check if points are inside the triangle
//                if isInside(t: tp, x: ix, y: iy) {
//                    let ip = iy*w + ix
//                    pixels[ip] = Pixel(white: 0.2)
//                }
                
                let p = Vec3(Float(ix) + 0.5, Float(iy) + 0.5, 0)
                let w0 = edgeFunction(tp[2], tp[1], p)
                let w1 = edgeFunction(tp[0], tp[2], p)
                let w2 = edgeFunction(tp[1], tp[0], p)
                let isInside = w0>0 && w1>0 && w2>0
                if isInside {
                    // barycentric coordinates
                    let bw0 = w0 / area
                    let bw1 = w1 / area
                    let bw2 = w2 / area
                    
                    let r = bw0 * Float(tc[0].r) + bw1 * Float(tc[1].r) + bw2 * Float(tc[2].r)
                    let g = bw0 * Float(tc[0].g) + bw1 * Float(tc[1].g) + bw2 * Float(tc[2].g)
                    let b = bw0 * Float(tc[0].b) + bw1 * Float(tc[1].b) + bw2 * Float(tc[2].b)
                    let ip = iy*w + ix
                    pixels[ip] = Pixel(r: UInt8(r*255), g: UInt8(g*255), b: UInt8(b*255))
                }
            }
        }
        
        // edges - interpolate between projected vertices
        for i in 0..<3 {
            let v1 = tp[i]
            let v2 = tp[(i+1)%3]
            
            let dx = v2.x - v1.x
            let dy = v2.y - v1.y
            let dist = sqrt(dx*dx + dy*dy)
            
            for step in stride(from: 0.0, through: dist, by: 1.0) {
                let f = step/dist
                let x_lerp = v1.x + f * dx
                let y_lerp = v1.y + f * dy
                
                let idx = Int(y_lerp)*w + Int(x_lerp)
                pixels[idx] = Pixel(white: 0.5)
            }
        }
        
        // projected vertices
        for vp in tp {
            let idx = Int(vp.y)*w + Int(vp.x)
            pixels[idx] = Pixel(white: 1.0)
        }
    }
    
    // https://www.scratchapixel.com/lessons/3d-basic-rendering/rasterization-practical-implementation/rasterization-stage.html
    func edgeFunction(_ a: Vec3, _ b: Vec3, _ c: Vec3) -> Float {
        (c.x - a.x) * (b.y - a.y) - (c.y - a.y) * (b.x - a.x)
    }
    
    // https://www.baeldung.com/cs/check-if-point-is-in-2d-triangle
    
    func isInside2(t: [Vec3], x: Int, y: Int) -> Bool {
        let p = Vec3(Float(x), Float(y), 0)
        let o0 = orientation(t[0], t[1], p)
        let o1 = orientation(t[1], t[2], p)
        let o2 = orientation(t[2], t[0], p)
        let sum = o0 + o1 + o2
        return sum == 3
    }
    
    func orientation(_ A: Vec3, _ B: Vec3, _ C: Vec3) -> Int {
        let AB = B-A
        let AC = C-A
        let cross0 = cross(AB, AC)
        // cannot use cross(v1, v2).len because len squares fields and loses orientation
        // since vectors start with z=0, then the cross result is in z (perpendicular to xy plane)
        return (cross0.z > 0) ? 1 : -1
//        let cross = AB.x*AC.y - AB.y*AC.x
//        return cross > 0 ? 1 : -1
    }
    
    func isInside(t: [Vec3], x: Int, y: Int) -> Bool {
        var AB = t[1] - t[0]
        var BC = t[2] - t[1]
        var CA = t[0] - t[2]
        AB.z = 0
        BC.z = 0
        CA.z = 0
        let p = Vec3(Float(x), Float(y), 0)
        let p1 = t[0] - p
        let p2 = t[1] - p
        let p3 = t[2] - p
        
        // cannot use cross(v1, v2).len because len squares fields and loses orientation
        // since vectors start with z=0, then the cross result is in z (perpendicular to xy plane)
        let c0 = cross(p1, AB).z > 0
        let c1 = cross(p2, BC).z > 0
        let c2 = cross(p3, CA).z > 0
        
        return c0 && c1 && c2
    }
    
    func renderBox() {
        let box = Geo.box
        for v in box {
            let z = v.z
            let y = v.y / z
            let x = v.x / z
            
            let rx = Int(floor(x * Float(w/3) + Float(w/3)))
            let ry = Int(floor(y * Float(h/3) + Float(h/3)))
            
            let idx = ry*w + rx
            pixels[idx] = Pixel(white: 1.0)
        }
    }
}

struct Vec3: ExpressibleByArrayLiteral {

    var x, y, z : Float
    
    init(_ x: Float, _ y: Float, _ z: Float) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    init(arrayLiteral elements: Float...) {
        precondition(elements.count == 3)
        x = elements[0]
        y = elements[1]
        z = elements[2]
    }
    
    var len: Float {
        sqrt(x*x + y*y + z*z)
    }
    
    mutating func norm() {
        let len = len
        x /= len
        y /= len
        z /= len
    }
}

func +(v1: Vec3, v2: Vec3) -> Vec3 {
    Vec3(v1.x + v2.x,
         v1.y + v2.y,
         v1.z + v2.z)
}

func -(v1: Vec3, v2: Vec3) -> Vec3 {
    Vec3(v1.x - v2.x,
         v1.y - v2.y,
         v1.z - v2.z)
}

func cross(_ v1: Vec3, _ v2: Vec3) -> Vec3 {
    Vec3(v1.y * v2.z - v1.z * v2.y,
         v1.z * v2.x - v1.x * v2.z,
         v1.x * v2.y - v1.y * v2.x)
}
