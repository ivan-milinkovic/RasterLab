import Foundation


class Geo {
    
    static let triangle: [Vec3] = [
        [0.5, 0.0, 1.0],
        [1.0, 1.0, 1.0],
        [0.0, 1.0, 1.0]
    ]
    
    static let triangle2: [Vec3] = [
        [ 0.0, 0.0, 0.0],
        [ 0.5, 0.5, 0.0],
        [-0.5, 0.5, 0.0]
    ]
    
    static let triangleColors: [Pixel] = [
        [1, 0, 0],
        [0, 1, 0],
        [0, 0, 1]
    ]
    
    static let grayColors: [Pixel] = [
        [0.9, 0.9, 0.9],
        [0.9, 0.9, 0.9],
        [0.9, 0.9, 0.9]
    ]
    
    static let whiteColors: [Pixel] = [
        [1, 1, 1],
        [1, 1, 1],
        [1, 1, 1]
    ]
    
    static let box: [Vec3] = [
        [1.0,  1.0, -1.0],
        [1.0,  1.0, -3.0],
        [1.0, -1.0, -1.0],
        [1.0, -1.0, -3.0],
        [-1.0,  1.0, -1.0],
        [-1.0,  1.0, -3.0],
        [-1.0, -1.0, -1.0],
        [-1.0, -1.0, -3.0]
    ]
}
