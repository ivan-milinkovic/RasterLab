import Foundation

struct Matrix4 {
    let m11, m12, m13, m14,
        m21, m22, m23, m24,
        m31, m32, m33, m34,
        m41, m42, m43, m44
        : Float
}

extension Matrix4: Equatable { }


func mult(_ m1: Matrix4, _ m2: Matrix4) -> Matrix4 {
    
    let m11 = m1.m11 * m2.m11  +  m1.m12 * m2.m21  +  m1.m13 * m2.m31  +  m1.m14 * m2.m41
    let m12 = m1.m11 * m2.m12  +  m1.m12 * m2.m22  +  m1.m13 * m2.m32  +  m1.m14 * m2.m42
    let m13 = m1.m11 * m2.m13  +  m1.m12 * m2.m23  +  m1.m13 * m2.m33  +  m1.m14 * m2.m43
    let m14 = m1.m11 * m2.m14  +  m1.m12 * m2.m24  +  m1.m13 * m2.m34  +  m1.m14 * m2.m44
    
    let m21 = m1.m21 * m2.m11  +  m1.m22 * m2.m21  +  m1.m23 * m2.m31  +  m1.m24 * m2.m41
    let m22 = m1.m21 * m2.m12  +  m1.m22 * m2.m22  +  m1.m23 * m2.m32  +  m1.m24 * m2.m42
    let m23 = m1.m21 * m2.m13  +  m1.m22 * m2.m23  +  m1.m23 * m2.m33  +  m1.m24 * m2.m43
    let m24 = m1.m21 * m2.m14  +  m1.m22 * m2.m24  +  m1.m23 * m2.m34  +  m1.m24 * m2.m44
    
    let m31 = m1.m31 * m2.m11  +  m1.m32 * m2.m21  +  m1.m33 * m2.m31  +  m1.m34 * m2.m41
    let m32 = m1.m31 * m2.m12  +  m1.m32 * m2.m22  +  m1.m33 * m2.m32  +  m1.m34 * m2.m42
    let m33 = m1.m31 * m2.m13  +  m1.m32 * m2.m23  +  m1.m33 * m2.m33  +  m1.m34 * m2.m43
    let m34 = m1.m31 * m2.m14  +  m1.m32 * m2.m24  +  m1.m33 * m2.m34  +  m1.m34 * m2.m44
    
    let m41 = m1.m41 * m2.m11  +  m1.m42 * m2.m21  +  m1.m43 * m2.m31  +  m1.m44 * m2.m41
    let m42 = m1.m41 * m2.m12  +  m1.m42 * m2.m22  +  m1.m43 * m2.m32  +  m1.m44 * m2.m42
    let m43 = m1.m41 * m2.m13  +  m1.m42 * m2.m23  +  m1.m43 * m2.m33  +  m1.m44 * m2.m43
    let m44 = m1.m41 * m2.m14  +  m1.m42 * m2.m24  +  m1.m43 * m2.m34  +  m1.m44 * m2.m44
    
    return Matrix4(m11: m11, m12: m12, m13: m13, m14: m14,
                   m21: m21, m22: m22, m23: m23, m24: m24,
                   m31: m31, m32: m32, m33: m33, m34: m34,
                   m41: m41, m42: m42, m43: m43, m44: m44)
}


struct Mat4 {
    let m: [Float] // row major
    init() {
        m = [Float].init(repeating: 0, count: 16)
    }
    init(_ ms: [Float]) {
        m = ms
    }
}

extension Mat4: Equatable { }

func mult2(_ m1: Mat4, _ m2: Mat4) -> Mat4 {
    var res = [Float](repeating: 0, count: 16)
    // iterating the result indexes
    var i=0; while i<16 { defer { i+=1 }
        let row = i / 4
        let col = i % 4
        
        let m1_offset = row * 4
        var j=0; while j<4 { defer { j+=1 }
            let m1_ind = m1_offset + j
            let m2_ind = j*4 + col
            
            res[row*4 + col] += m1.m[m1_ind] * m2.m[m2_ind]
        }
    }
    return Mat4(res)
}