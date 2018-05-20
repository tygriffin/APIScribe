//
//  DynamicKey.swift
//  Serialization
//
//  Created by Taylor Griffin on 20/5/18.
//

struct DynamicKey : CodingKey {
    var stringValue: String
    init?(stringValue: String) {
        self.stringValue = stringValue
    }
    var intValue: Int? { return nil }
    init?(intValue: Int) { return nil }
}
