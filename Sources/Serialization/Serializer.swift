//
//  Serializer.swift
//  Serialization
//
//  Created by Taylor Griffin on 12/5/18.
//


protocol Serializer : Storable {
    var fields: [Field] { get }
    var resources: [Resource] { get }
    
    var storeKey: String { get }
    var storeId: String { get }
    
    init()
}



extension Serializer {
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicKey.self)
        for field in fields {
            try container.encode(field, forKey: DynamicKey(stringValue: field.key)!)
        }
    }
    
    var storeKey: String {
        return Self.type.rawValue
    }
}
