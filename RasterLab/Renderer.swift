import Foundation

let renderer = Renderer()

class Renderer {
    var frameBuffer: FrameBuffer
    let w = 200
    let h = 200
    
    init() {
        frameBuffer = FrameBuffer(w: w, h: h)
        
    }
    
    func render() {
//        let t0 = Date()
//        renderBox()
//        renderTriangle()
//        fillEdges()
        renderTriangle2()
//        renderLine()
//        let dt = Date().timeIntervalSince(t0)*1_000_000
//        print("\(dt)us")
    }
    
    func renderTriangle2() {
        let t = Geo.triangle2
        let tc = Geo.triangleColors
        let wf = Float(w)
        let hf = Float(h)
        
        var tv = t // tv - triangle in view space

        tv = [Vec3]()
        let radsInDeg = Float.pi / 180
        let az = 20 * radsInDeg
        let Rz = Mat3(m11:  cos(az), m12: sin(az), m13: 0,
                      m21: -sin(az), m22: cos(az), m23: 0,
                      m31: 0,        m32: 0,       m33: 1)
        
        let ay = 45 * radsInDeg
        let Ry = Mat3(m11: cos(ay), m12: 0, m13: sin(ay),
                      m21: 0,       m22: 1, m23: 0,
                      m31: sin(ay), m32: 0, m33: cos(ay))
        
        let ax = 70 * radsInDeg
        let Rx = Mat3(m11: 1, m12:  0,       m13: 0,
                      m21: 0, m22:  cos(ax), m23: sin(ax),
                      m31: 0, m32: -sin(ax), m33: cos(ax))
        
        for v in t {
            var vv = v * Ry  // vertex in view space
            vv = vv + Vec3(0.5, 0, 1)
            tv.append(vv)
        }
        
        // project triangle
        var tp = [Vec3]() // triangle projected
        tp.reserveCapacity(t.count)
        for v in tv {
            let z = v.z
            let y = v.y / z
            let x = v.x / z
            
            let xp = x*wf*0.98 // + wf*0.1
            let yp = y*hf*0.98 // + hf*0.1
            
            let vp = Vec3(xp, yp, z)
            tp.append(vp)
        }
        
        // fill triangle
        let area = abs(edgeFunction(tp[0], tp[1], tp[2]))
        
        // bounding box
        let xmin = Int(min(tp[0].x, min(tp[1].x, tp[2].x)))
        let ymin = Int(min(tp[0].y, min(tp[1].y, tp[2].y)))
        let xmax = Int(max(tp[0].x, max(tp[1].x, tp[2].x)))
        let ymax = Int(max(tp[0].y, max(tp[1].y, tp[2].y)))
        for ix in xmin...xmax {
            for iy in ymin...ymax {
                // check if points are inside the triangle
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
                    
                    // set pixel
                    let r = bw0 * Float(tc[0].r) + bw1 * Float(tc[1].r) + bw2 * Float(tc[2].r)
                    let g = bw0 * Float(tc[0].g) + bw1 * Float(tc[1].g) + bw2 * Float(tc[2].g)
                    let b = bw0 * Float(tc[0].b) + bw1 * Float(tc[1].b) + bw2 * Float(tc[2].b)
                    frameBuffer[ix, iy] = Pixel(r: UInt8(r*255), g: UInt8(g*255), b: UInt8(b*255))
                }
            }
        }
        
        // draw edges - interpolate between projected vertices
        for i in 0..<3 {
            let v1 = tp[i]
            let v2 = tp[(i+1)%3]
            
            let dx = v2.x - v1.x
            let dy = v2.y - v1.y
            let dist = sqrt(dx*dx + dy*dy)
            
            for step in stride(from: 0.0, through: dist, by: 1.0) {
                let f = step/dist
                let x_lerp = Int(v1.x + f * dx)
                let y_lerp = Int(v1.y + f * dy)
                frameBuffer[x_lerp, y_lerp] = Pixel(white: 0.5)
            }
        }
        
        // draw projected vertices
        for vp in tp {
            frameBuffer[Int(vp.x), Int(vp.y)] = Pixel(white: 1.0)
        }
    }
    
    func fillEdges() {
        for x in 0..<w {
            frameBuffer[x] = Pixel(white: 0.5)
            let i = (h-1)*w + x
            frameBuffer[i] = Pixel(white: 0.5)
        }
        for y in 0..<h {
            var i = y*w + 0
            frameBuffer[i] = Pixel(white: 0.5)
            i = y*w + w-1
            frameBuffer[i] = Pixel(white: 0.5)
        }
    }
    
    func renderLine() {
        let v1: Vec3 = [0,0,0]
        let v2: Vec3 = [100,100,0]
        
        let idx1 = Int(v1.y)*w + Int(v1.x)
        let idx2 = Int(v2.y)*w + Int(v2.x)
        frameBuffer[idx1] = Pixel(white: 1.0)
        frameBuffer[idx2] = Pixel(white: 1.0)
        
        let dx = v2.x - v1.x
        let dy = v2.y - v1.y
        let dist = sqrt(dx*dx + dy*dy)
        
        for step in stride(from: 0.0, through: dist, by: 1.0) {
            let f = step/dist
            let x_lerp = v1.x + f * dx
            let y_lerp = v1.y + f * dy
            
            let idx = Int(y_lerp)*w + Int(x_lerp)
            frameBuffer[idx] = Pixel(white: 0.8)
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
                    frameBuffer[ip] = Pixel(r: UInt8(r*255), g: UInt8(g*255), b: UInt8(b*255))
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
                frameBuffer[idx] = Pixel(white: 0.5)
            }
        }
        
        // projected vertices
        for vp in tp {
            let idx = Int(vp.y)*w + Int(vp.x)
            frameBuffer[idx] = Pixel(white: 1.0)
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
            frameBuffer[idx] = Pixel(white: 1.0)
        }
    }
}
