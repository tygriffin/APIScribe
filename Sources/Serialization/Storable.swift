//
//  Storable.swift
//  Serialization
//
//  Created by Taylor Griffin on 12/5/18.
//

public protocol Storable : Encodable {
    static var type: String { get }
}

struct DynamicKey : CodingKey {
    var stringValue: String
    init?(stringValue: String) {
        self.stringValue = stringValue
    }
    var intValue: Int? { return nil }
    init?(intValue: Int) { return nil }
}

struct AnyStorable : Encodable {
    var base: Storable
    
    init(_ base: Storable) {
        self.base = base
    }
    
    func encode(to encoder: Encoder) throws {
        try base.encode(to: encoder)
    }
}
