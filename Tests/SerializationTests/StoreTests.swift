//
//  StoreTests.swift
//  SerializationTests
//
//  Created by Taylor Griffin on 20/5/18.
//

import XCTest
@testable import Serialization

struct SomeStorable : Storable {
    static var type = "somestorable"
    
    var storeKey = "somestorablekey"
    var storeIdString = "somestorableid"
    
    var value = ""
}

final class StoreTests: XCTestCase {
    
    static var allTests = [
        ("testIsAlreadySerialized", testIsAlreadySerialized),
        ("testAdd", testAdd),
    ]
    
    func testIsAlreadySerialized() throws {
        var store = Store()
        XCTAssertFalse(store.isAlreadySerialized(key: "somekey", id: "someid"))
        
        store["somekey"] = ["otherid": SomeStorable()]
        XCTAssertFalse(store.isAlreadySerialized(key: "somekey", id: "someid"))
        
        store["somekey"] = ["someid": SomeStorable()]
        XCTAssertTrue(store.isAlreadySerialized(key: "somekey", id: "someid"))
    }
    
    func testAdd() {
        var store = Store()
        
        store.add(storable: SomeStorable(
            storeKey: "keyone",
            storeIdString: "idone",
            value: "One"))
        
        if let storable = store["keyone"]?["idone"] as? SomeStorable {
            XCTAssertEqual(storable.value, "One")
        } else {
            XCTFail("Storable not added")
        }
        
        // Using the same key and id will overwrite existing value if it exists
        store.add(storable: SomeStorable(
            storeKey: "keyone",
            storeIdString: "idone",
            value: "Uno"))
        
        if let storable = store["keyone"]?["idone"] as? SomeStorable {
            XCTAssertEqual(storable.value, "Uno")
        } else {
            XCTFail("Storable not added")
        }
        
        // Adding a value to the same key, different id
        XCTAssertEqual(store["keyone"]?.count, 1)
        store.add(storable: SomeStorable(
            storeKey: "keyone",
            storeIdString: "idtwo",
            value: "Two"))
        
        XCTAssertEqual(store["keyone"]?.count, 2)
        if let storable = store["keyone"]?["idtwo"] as? SomeStorable {
            XCTAssertEqual(storable.value, "Two")
        } else {
            XCTFail("Storable not added")
        }
        
        // Adding a value to a different key
        XCTAssertEqual(store.count, 1)
        store.add(storable: SomeStorable(
            storeKey: "keytwo",
            storeIdString: "idone",
            value: "Second key, first id"))
        
        XCTAssertEqual(store.count, 2)
        if let storable = store["keytwo"]?["idone"] as? SomeStorable {
            XCTAssertEqual(storable.value, "Second key, first id")
        } else {
            XCTFail("Storable not added")
        }
    }
}
