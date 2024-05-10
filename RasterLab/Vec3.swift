import Foundation

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

func *(v: Vec3, c: Float) -> Vec3 {
    Vec3(v.x * c,
         v.y * c,
         v.z * c)
}
