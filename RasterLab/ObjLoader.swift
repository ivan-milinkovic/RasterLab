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
    var indices = [[(vi: Int, ni: Int)]]() // (vertex_index, normal_index)
    var normals = [Vec3]()
    for line in lines {
        let comps = line.components(separatedBy: .whitespaces)
//        print(comps)
        switch comps[0] {
        case "v":
            // v 1.000000 1.000000 -1.000000
            let coords = comps.suffix(from: 1).map { Float($0)! }
            vertices.append(Vec3(coords[0], coords[1], coords[2]))
        
        case "vn":
            let coords = comps.suffix(from: 1).map { Float($0)! }
            normals.append(Vec3(coords[0], coords[1], coords[2]))
            
        case "f":
            // f 5/1/1 3/2/1 1/3/1
            // vertex/texture/normal
            let faceIndices = comps.suffix(from: 1).map { vtnStr in
                let vtn = vtnStr.split(separator: "/").map { Int($0)! - 1 } // .obj file indexes start with 1
                let vertexIndex = vtn[0]
                let normalIndex = vtn[2]
                return (Int(vertexIndex), Int(normalIndex))
            }
            indices.append(faceIndices)
            break
            
        default:
            break
        }
    }
    
    let triangles = indices.map { ind in
        // blender vertex order vs my edge function vertex order
        let vs = [vertices[ind[2].vi], vertices[ind[1].vi], vertices[ind[0].vi]]
        let ns = [normals[ind[2].ni], normals[ind[1].ni], normals[ind[0].ni]]
        return Triangle(vertices: vs, normals: ns)
    }
    
    return triangles
}

struct Triangle {
    
    let vertices: [Vec3]
    let normals: [Vec3]
    
    init(vertices: [Vec3], normals: [Vec3]) {
        self.vertices = vertices
        self.normals = normals
    }
    
}
