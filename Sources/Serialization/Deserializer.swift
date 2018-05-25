//
//  Deserializer.swift
//  Serialization
//
//  Created by Taylor Griffin on 19/5/18.
//

import Foundation

public protocol Deserializer : Decodable {
    associatedtype Model
    var model: Model { get set }
    func makeFields(builder: inout FieldBuilder<Model>)
    init()
}

extension Deserializer {
    
    public init(from decoder: Decoder) throws {
        
        self.init()
        
        if let d = decoder.userInfo[CodingUserInfoKey(rawValue: "serialization.deserializer")!] as? Self {
            self = d
        }
        
        if let model = decoder.userInfo[CodingUserInfoKey(rawValue: "serialization.model")!] as? Model {
            self.model = model
        }
        
        let container = try decoder.container(keyedBy: DynamicKey.self)
        
        var builder = FieldBuilder<Model>(model: model)
        makeFields(builder: &builder)
        
        for field in builder.fields {
            if field.shouldDecode() {
                let key = DynamicKey(stringValue: field.key)!
                
                // String
                try decode(field, container, key, \.stringDecode)
                try decodeOptional(field, container, key, \.stringDecodeOptional)
                
                // Int
                try decode(field, container, key, \.intDecode)
                try decodeOptional(field, container, key, \.intDecodeOptional)
                
                // Decimal
                try decode(field, container, key, \.decimalDecode)
                try decodeOptional(field, container, key, \.decimalDecodeOptional)
                
                // Double
                try decode(field, container, key, \.doubleDecode)
                try decodeOptional(field, container, key, \.doubleDecodeOptional)
                
                // Bool
                try decode(field, container, key, \.boolDecode)
                try decodeOptional(field, container, key, \.boolDecodeOptional)
              
                // Date
                try decode(field, container, key, \.dateDecode)
                try decodeOptional(field, container, key, \.dateDecodeOptional)
                
                
                if field.referencingInternalModel {
                    model = builder.model
                } else {
                    builder.model = model
                }
            }
        }
    }
    
    private func decode<T: Decodable>(
        _ field: Field,
        _ container: KeyedDecodingContainer<DynamicKey>,
        _ key: DynamicKey,
        _ path: KeyPath<Field, ((T)->Void)?>) throws {
        
        if let d = field[keyPath: path] {
            if let v = try container.decodeIfPresent(T.self, forKey: key) {
                d(v)
            }
        }
    }
    
    private func decodeOptional<T: Decodable>(
        _ field: Field,
        _ container: KeyedDecodingContainer<DynamicKey>,
        _ key: DynamicKey,
        _ path: KeyPath<Field, ((T?)->Void)?>) throws {
        
        if let d = field[keyPath: path] {
            do {
                let v = try container.decode(T?.self, forKey: key)
                d(v)
            } catch DecodingError.keyNotFound {}
        }
    }
}
