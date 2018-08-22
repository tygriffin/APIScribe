//
//  StoreTests.swift
//  APIScribeTests
//
//  Created by Taylor Griffin on 20/5/18.
//

import XCTest
@testable import APIScribe

struct SomeStorable : Storable {
    static var storeKey = "somekey"
    
    var storeId = "someid"
    
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
        
        store.storage["somekey"] = ["otherid": SomeStorable()]
        XCTAssertFalse(store.isAlreadySerialized(key: "somekey", id: "someid"))
        
        store.storage["somekey"] = ["someid": SomeStorable()]
        XCTAssertTrue(store.isAlreadySerialized(key: "somekey", id: "someid"))
    }
    
    func testAdd() {
        var store = Store()
        
        store.add(storable: SomeStorable(
            storeId: "idone",
            value: "One")
        )
        
        if let storable = store.storage["somekey"]?["idone"] as? SomeStorable {
            XCTAssertEqual(storable.value, "One")
        } else {
            XCTFail("Storable not added")
        }
        
        // Using the same key and id will overwrite existing value if it exists
        store.add(storable: SomeStorable(
            storeId: "idone",
            value: "Uno")
        )
        
        if let storable = store.storage["somekey"]?["idone"] as? SomeStorable {
            XCTAssertEqual(storable.value, "Uno")
        } else {
            XCTFail("Storable not added")
        }
        
        // Adding a value to the same key, different id
        XCTAssertEqual(store.storage["somekey"]?.count, 1)
        store.add(storable: SomeStorable(
            storeId: "idtwo",
            value: "Two"))
        
        XCTAssertEqual(store.storage["somekey"]?.count, 2)
        if let storable = store.storage["somekey"]?["idtwo"] as? SomeStorable {
            XCTAssertEqual(storable.value, "Two")
        } else {
            XCTFail("Storable not added")
        }
        
        // Adding a value to a different key
        XCTAssertEqual(store.storage.count, 1)
        SomeStorable.storeKey = "differentkey"
        store.add(storable: SomeStorable(
            storeId: "idone",
            value: "Second key, first id"))
        
        XCTAssertEqual(store.storage.count, 2)
        if let storable = store.storage["differentkey"]?["idone"] as? SomeStorable {
            XCTAssertEqual(storable.value, "Second key, first id")
        } else {
            XCTFail("Storable not added")
        }
    }
}
