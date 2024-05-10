//
//  ObjLoader.swift
//  RasterLab
//
//  Created by Ivan Milinkovic on 10.5.24..
//

import Foundation

func loadObj(_ url: URL) -> [Triangle] {
    let str = try! String(contentsOf: url)
    let lines = str.components(separatedBy: .newlines)
    
    var vertices = [Vec3]()
    var vIndices = [[Int]]()
    for line in lines {
        let comps = line.components(separatedBy: .whitespaces)
//        print(comps)
        switch comps[0] {
        case "v":
            // v 1.000000 1.000000 -1.000000
            let coords = comps.suffix(from: 1).map { Float($0)! }
            vertices.append(Vec3(coords[0], coords[1], coords[2]))
            
        case "f":
            // f 5/1/1 3/2/1 1/3/1
            // vertex/texture/normal
            let faceIndices = comps.suffix(from: 1).map { vtnStr in
                let vtn = vtnStr.split(separator: "/").map { Int($0)! - 1 } // obj indexes a first element with 1
                let vertexIndex = vtn[0]
                return Int(vertexIndex)
            }
            vIndices.append(faceIndices)
            break
            
        default:
            break
        }
    }
    
    let triangles = vIndices.map { ind in
//        Triangle(vertices[ind[0]], vertices[ind[1]], vertices[ind[2]])
        Triangle(vertices[ind[2]], vertices[ind[1]], vertices[ind[0]]) // blender vertex order vs my edge function vertex order
    }
    
    return triangles
}

struct Triangle {
    
    let vs: [Vec3]
    
    init(_ v1: Vec3, _ v2: Vec3, _ v3: Vec3) {
        vs = [v1, v2, v3]
    }
    
}
