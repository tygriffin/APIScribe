//
//  Builders.swift
//  Serialization
//
//  Created by Taylor Griffin on 19/5/18.
//

import Foundation

/**
 Convenient abstraction for building up fields.
 */
public class FieldBuilder<S: ModelHolder> {
    public typealias M = S.Model
    private var modelHolder: S
    
    var encodingContainer: KeyedEncodingContainer<DynamicKey>?
    var decodingContainer: KeyedDecodingContainer<DynamicKey>?
    
    init(modelHolder: S) {
        self.modelHolder = modelHolder
    }
    
    public func field<Type: Codable>(
        _ key: String,
        _ value: Type?,
        _ decoder: @escaping (Type) -> Void,
        shouldEncode: @autoclosure @escaping () -> Bool = true,
        shouldDecode: @autoclosure @escaping () -> Bool = true
    ) throws {
        
        let codingKey = DynamicKey(stringValue: key)
        
        if var container = encodingContainer {
            if shouldEncode() {
                try container.encode(value, forKey: codingKey)
            }
        }
        
        if let container = decodingContainer {
            if shouldDecode() {
                do {
                    let nextValue = try container.decode(Type.self, forKey: codingKey)
                    decoder(nextValue)
                } catch DecodingError.keyNotFound(_, _) {}
            }
        }
    }
    
    public func field<Type: Codable>(
        _ key: String,
        _ path: WritableKeyPath<S.Model,Type>,
        shouldEncode: @autoclosure @escaping () -> Bool = true,
        shouldDecode: @autoclosure @escaping () -> Bool = true
    ) throws {
        try self.field(
            key,
            modelHolder.model[keyPath: path],
            { self.modelHolder.model[keyPath: path] = $0 },
            shouldEncode: shouldEncode,
            shouldDecode: shouldDecode
        )
    }
}

/**
 Convenient abstraction for adding Resources.
 */
public struct SideLoadedResourceBuilder {
    var resources: [Resource] = []
    
    mutating public func add(_ resource: SerializerProducer) {
        resources.append(Resource(resource))
    }
    
    mutating public func add(_ _resources: [SerializerProducer]) {
        for resource in _resources {
            resources.append(Resource(resource))
        }
    }
}
