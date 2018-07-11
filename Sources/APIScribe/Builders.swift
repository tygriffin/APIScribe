//
//  Builders.swift
//  APIScribe
//
//  Created by Taylor Griffin on 19/5/18.
//

import Foundation

/**
 Convenient abstraction for building up fields.
 */
public class FieldBuilder<S: ModelHolder & ContextHolder> {
    public typealias M = S.Model
    internal var readOnlyFields: [String] = []
    private var serializer: S
    
    var encodingContainer: KeyedEncodingContainer<DynamicKey>?
    var decodingContainer: KeyedDecodingContainer<DynamicKey>?
    
    init(modelHolder: S) {
        self.serializer = modelHolder
    }
    
    // MARK: Base field methods
    
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
                if !shouldDecode() {
                    readOnlyFields.append(key)
                }
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
    
    public func readOnly<Type: Codable>(
        _ key: String,
        _ value: Type?,
        shouldEncode: @autoclosure @escaping () -> Bool = true
        ) throws {
        
        try self.field(key, value, { _ in }, shouldEncode: shouldEncode, shouldDecode: false)
    }
    
    public func writeOnly<Type: Codable>(
        _ key: String,
        _ decoder: @escaping (Type) -> Void,
        shouldDecode: @autoclosure @escaping () -> Bool = true
        ) throws {
        
        try self.field(key, nil, decoder, shouldEncode: false, shouldDecode: shouldDecode)
    }
    
    // MARK: KeyPath conveniences
    
    public func field<Type: Codable>(
        _ key: String,
        _ path: WritableKeyPath<S.Model,Type>,
        shouldEncode: @autoclosure @escaping () -> Bool = true,
        shouldDecode: @autoclosure @escaping () -> Bool = true
    ) throws {
        try self.field(
            key,
            serializer.model[keyPath: path],
            { self.serializer.model[keyPath: path] = $0 },
            shouldEncode: shouldEncode,
            shouldDecode: shouldDecode
        )
    }
    
    public func readOnly<Type: Codable>(
        _ key: String,
        _ path: KeyPath<S.Model,Type>,
        shouldEncode: @autoclosure @escaping () -> Bool = true
        ) throws {
        try self.readOnly(
            key,
            serializer.model[keyPath: path],
            shouldEncode: shouldEncode
        )
    }
    
    public func writeOnly<Type: Codable>(
        _ key: String,
        _ path: WritableKeyPath<S.Model,Type>,
        shouldDecode: @autoclosure @escaping () -> Bool = true
        ) throws {
        
        try self.writeOnly(
            key,
            { self.serializer.model[keyPath: path] = $0 },
            shouldDecode: false
        )
    }
    
    // MARK: Embedded resource methods
    
    public func embeddedResource<Type: Serializable>(
        _ key: String,
        _ value: Type?,
        _ decoder: @escaping (Type) -> Void,
        shouldEncode: @autoclosure @escaping () -> Bool = true,
        shouldDecode: @autoclosure @escaping () -> Bool = true
        ) throws where Type.ModelSerializer: EncodeSerializer & DecodeSerializer {
        
        let serializer = value?.makeSerializer(in: self.serializer.context)
        try self.field(
            key,
            serializer,
            { if let v = $0.model as? Type { decoder(v) } },
            shouldEncode: shouldEncode(),
            shouldDecode: shouldDecode()
        )
    }
    
    public func readOnlyEmbeddedResource<Type: Serializable>(
        _ key: String,
        _ value: Type?,
        shouldEncode: @autoclosure @escaping () -> Bool = true
        ) throws where Type.ModelSerializer: EncodeSerializer & DecodeSerializer {
        
        try self.embeddedResource(
            key,
            value,
            { _ in },
            shouldEncode: shouldEncode(),
            shouldDecode: false
        )
    }
    
    public func writeOnlyEmbeddedResource<S: DecodeSerializer & EncodeSerializer>(
        _ key: String,
        _ decoder: @escaping (S.Model) -> Void,
        using deserializerType: S.Type,
        shouldDecode: @autoclosure @escaping () -> Bool = true
        ) throws {

        var deserializer = deserializerType.init()
        deserializer.context = self.serializer.context

        try self.field(
            key,
            deserializer,
            { decoder($0.model) },
            shouldEncode: false,
            shouldDecode: shouldDecode()
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
