//
//  Renderer+RenderTriangle.swift
//  RasterLab
//
//  Created by Ivan Milinkovic on 19.5.24..
//

import Foundation

extension Renderer {
    
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
    
    func renderBoxVertices() {
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
    
}
