import Foundation

let renderer = Renderer()

class Renderer {
    
    var frameBuffer: FrameBuffer
    private var depthBuffer: DepthBuffer
    let w = 640
    let h = 480
    var shade = true
    var wireframe = false
    var showDepthBuffer = false
    private let useDepthBufferForWireframe = true
    
    // manual positioning
    private var angleY: Float = 0.0
    private var angleX: Float = 90.0
    private var depthOffset: Float = 4.0
    
    private let meshTriangles: [Triangle]
    
    private let lightPos = Vec3(0.25, 0, 0)
    private var lightDir: Vec3
    
    var lastRenderTimeMs: Double = -1
    
    init() {
        frameBuffer = FrameBuffer(w: w, h: h)
        depthBuffer = DepthBuffer(w: w, h: h)
        
        lightDir = lightPos
        lightDir.norm()
        
//        let url = Bundle.main.url(forResource: "box.obj", withExtension: nil)!
        let url = Bundle.main.url(forResource: "monkey.obj", withExtension: nil)!
        meshTriangles = loadObj(url)
    }

    func render() {
        let t0 = Date()
        
        frameBuffer.clear()
        depthBuffer.clear()
        
//        fillEdges()
//        renderLine()
//        renderTriangle()
//        renderBoxVertices()
        renderMesh()
          
        if showDepthBuffer {
            copyDepthBufferToFrameBuffer()
        }
        
        lastRenderTimeMs = Date().timeIntervalSince(t0)*1_000
    }
    
    func renderMesh() {
        for t in meshTriangles {
            renderMesh(t.vertices, t.normals)
        }
    }
    
    func renderMesh(_ triangleVertices: [Vec3], _ triangleNormals: [Vec3]) {
        let t = triangleVertices
        let ns = triangleNormals
//        let tc = Geo.grayColors
        let tc = Geo.whiteColors
        let wf = Float(w)
        let hf = Float(h)
        let wf2 = wf*0.5
        let hf2 = hf*0.5
        let aspect = wf/hf

        // Transform to camera space, tv - triangle in view space
        let tv = t.map { v in
            (v * rotMat) + Vec3(0, 0, depthOffset) // push object into the scene so it's easier to see
        }
        // transform normals, rotation only, translation makes no sense, as normals define orientation only, not position
        let nv = ns.map { $0 * rotMat }
        
        // project triangle to screen space
        var tp = [Vec3]() // triangle projected
        tp.reserveCapacity(t.count)
        for v in tv {
            let z = v.z
            let y = v.y / z
            let x = v.x / z / aspect
            
            let xp = x*wf2 + wf2
            let yp = y*hf2 + hf2
            
            let vp = Vec3(xp, yp, z)
            tp.append(vp)
        }
        
        // fill the triangle
        
        if shade {
            let area = abs(edgeFunction(tp[0], tp[1], tp[2]))
            
            // bounding box of the triangle
            let xmin = Int(min(tp[0].x, min(tp[1].x, tp[2].x)))
            let ymin = Int(min(tp[0].y, min(tp[1].y, tp[2].y)))
            let xmax = Int(max(tp[0].x, max(tp[1].x, tp[2].x)))
            let ymax = Int(max(tp[0].y, max(tp[1].y, tp[2].y)))
            // go through all the pixels in the bounding box
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
                        
                        // Check and update the depth buffer
                        let z = bw0 * tp[0].z + bw1 * tp[1].z + bw2 * tp[2].z
                        if z >= depthBuffer[ix, iy] {
                            // print("depth buffer, skipping \(ix), \(iy)")
                            continue
                        }
                        
                        depthBuffer[ix, iy] = z
                        
                        // Interpolate normals
                        let nx = bw0 * Float(nv[0].x) + bw1 * Float(nv[1].x) + bw2 * Float(nv[2].x)
                        let ny = bw0 * Float(nv[0].y) + bw1 * Float(nv[1].y) + bw2 * Float(nv[2].y)
                        let nz = bw0 * Float(nv[0].z) + bw1 * Float(nv[1].z) + bw2 * Float(nv[2].z)
                        var n = Vec3(nx, ny, nz)
                        n.norm()
                        
                        // calculate light
                        let lightFactor = max(0, dot(n, lightDir))
                        
                        // Interpolate vertex colors
                        var r = bw0 * Float(tc[0].r) + bw1 * Float(tc[1].r) + bw2 * Float(tc[2].r)
                        var g = bw0 * Float(tc[0].g) + bw1 * Float(tc[1].g) + bw2 * Float(tc[2].g)
                        var b = bw0 * Float(tc[0].b) + bw1 * Float(tc[1].b) + bw2 * Float(tc[2].b)
                        
                        r *= lightFactor
                        g *= lightFactor
                        b *= lightFactor
                        
                        frameBuffer[ix, iy] = Pixel(r: UInt8(r*255), g: UInt8(g*255), b: UInt8(b*255))
                    }
                }
            }
        }
        
        // draw edges of the triangle - interpolate between projected vertices
        if wireframe {
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
                    
                    if useDepthBufferForWireframe {
                        // Helper, alternatively all triangles should be shaded first then wireframed, not one by one, because wires get overwritten
                        let z_lerp = v1.z + (v2.z-v1.z) * f
                        if z_lerp >= depthBuffer[x_lerp, y_lerp] {
                            continue
                        }
                        depthBuffer[x_lerp, y_lerp] = z_lerp
                    }
                    
                    frameBuffer[x_lerp, y_lerp] = Pixel(white: 0.4)
                }
            }
            
            // draw projected vertices
            for vp in tp {
                frameBuffer[Int(vp.x), Int(vp.y)] = Pixel(white: 0.3)
            }
        }
    }
    
    // These matrices rotate around x, y, z which is the world space. (If you look down an axis, then rotation will look like a roll)
    // Ideally, make a camera, and rotate around the right, up and forward vectors (camera x, y, z)
    private var rotMat: Mat3 {
        let radsInDeg = Float.pi / 180
        
//        let az = 20 * radsInDeg
//        let Rz = Mat3(m11:  cos(az), m12: -sin(az), m13: 0,
//                      m21:  sin(az), m22:  cos(az), m23: 0,
//                      m31: 0,        m32: 0,       m33: 1)
//        return Rz
        
        let ay = angleY * radsInDeg
        let Ry = Mat3(m11: cos(ay), m12: 0, m13: sin(ay),
                      m21: 0,       m22: 1, m23: 0,
                      m31: -sin(ay), m32: 0, m33: cos(ay))
//        return Ry
        
        let ax = angleX * radsInDeg
        let Rx = Mat3(m11: 1, m12:  0,       m13: 0,
                      m21: 0, m22:  cos(ax), m23: -sin(ax),
                      m31: 0, m32:  sin(ax), m33:  cos(ax))
//        return Rx
        
        return Rx * Ry
        
//        return Mat3.identity
    }
    
    func rotate(dx: Float, dy: Float) {
        angleX -= dy * 1
        angleY += dx * 1
    }
    
    func translateDepth(_ dz: Float) {
        depthOffset = max(depthOffset - 0.5*dz, 2) // anything less than 2 results in division by 0 or extremely large values when projecting
        depthOffset = min(depthOffset, 20)
    }
    
    func copyDepthBufferToFrameBuffer() {
        for x in 0..<w {
            for y in 0..<h {
                let z = depthBuffer[x,y]
                let scaledZ = 1 - (min(z, 10) / 10) // 1 - x to invert colors, make larger z values map to lower gray values
                frameBuffer[x,y] = Pixel(white: Double(scaledZ))
            }
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
    
    
}
