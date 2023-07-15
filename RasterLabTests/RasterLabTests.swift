//
//  RasterLabTests.swift
//  RasterLabTests
//
//  Created by Ivan Milinkovic on 15.7.23..
//

import XCTest
@testable import RasterLab

final class RasterLabTests: XCTestCase {

    func testMat4Mult() throws {
        
        let m1 = Matrix4(m11: 1, m12: 2, m13: 3, m14: 4,
                         m21: 1, m22: 2, m23: 3, m24: 4,
                         m31: 1, m32: 2, m33: 3, m34: 4,
                         m41: 1, m42: 2, m43: 3, m44: 4)
        
        let m2 = Matrix4(m11: 1, m12: 2, m13: 3, m14: 4,
                         m21: 1, m22: 2, m23: 3, m24: 4,
                         m31: 1, m32: 2, m33: 3, m34: 4,
                         m41: 1, m42: 2, m43: 3, m44: 4)
        
        let result = mult(m1, m2)
        XCTAssertEqual(result, Matrix4(m11: 10.0, m12: 20.0, m13: 30.0, m14: 40.0,
                                       m21: 10.0, m22: 20.0, m23: 30.0, m24: 40.0,
                                       m31: 10.0, m32: 20.0, m33: 30.0, m34: 40.0,
                                       m41: 10.0, m42: 20.0, m43: 30.0, m44: 40.0))
    }

    func testMat4MultPerf() throws {
        let m1 = Matrix4(m11: 1, m12: 2, m13: 3, m14: 4,
                         m21: 1, m22: 2, m23: 3, m24: 4,
                         m31: 1, m32: 2, m33: 3, m34: 4,
                         m41: 1, m42: 2, m43: 3, m44: 4)
        
        let m2 = Matrix4(m11: 1, m12: 2, m13: 3, m14: 4,
                         m21: 1, m22: 2, m23: 3, m24: 4,
                         m31: 1, m32: 2, m33: 3, m34: 4,
                         m41: 1, m42: 2, m43: 3, m44: 4)
        
        measure {
            let _ = mult(m1, m2)
        }
    }

    func testMat4Mult2() throws {
        let m1 = Mat4([1,2,3,4, 1,2,3,4, 1,2,3,4, 1,2,3,4])
        let m2 = Mat4([1,2,3,4, 1,2,3,4, 1,2,3,4, 1,2,3,4])
        let result = mult2(m1, m2)
        let expectedValues : [Float] = [10.0, 20, 30, 40, 10.0, 20, 30, 40, 10.0, 20, 30, 40, 10.0, 20, 30, 40]
        let expected = Mat4(expectedValues)
        XCTAssertEqual(result, expected)
    }
    
    func testMat4Mult2Perf() throws {
        let m1 = Mat4([1,2,3,4, 1,2,3,4, 1,2,3,4, 1,2,3,4])
        let m2 = Mat4([1,2,3,4, 1,2,3,4, 1,2,3,4, 1,2,3,4])
        measure {
            let _ = mult2(m1, m2)
        }
    }
}
