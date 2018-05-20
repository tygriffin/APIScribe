//
//  FieldTests.swift
//  SerializationTests
//
//  Created by Taylor Griffin on 20/5/18.
//

import XCTest
@testable import Serialization

struct Container : Encodable {
    var field: Field
}

final class FieldTests: XCTestCase {
    
    static var allTests = [
        ("testEncode", testEncode),
        ]
    
    func testEncode() throws {
        var f = Field(key: "key")
        f.stringValue = "Hello"
        var data = try encodeField(f)
        var json = try data.toJSONObject()
        guard let objString = json as? [String: String] else {
            XCTFail("Unexpected result of serialization")
            return
        }
        
        XCTAssertEqual(objString["field"], "Hello")
        
        f.stringValue = nil
        f.intValue = 9
        
        data = try encodeField(f)
        json = try data.toJSONObject()
        guard let objInt = json as? [String: Int] else {
            XCTFail("Unexpected result of serialization")
            return
        }
        
        XCTAssertEqual(objInt["field"], 9)
    }
    
    private func encodeField(_ field: Field) throws -> Data {
        let container = Container(field: field)
        let jsonEncoder = JSONEncoder()
        return try jsonEncoder.encode(container)
    }
}

