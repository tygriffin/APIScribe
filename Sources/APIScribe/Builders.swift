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
        _ value: @autoclosure () throws -> Type?,
        _ decoder: @escaping (Type) throws -> Void,
        encodeWhen shouldEncode: @autoclosure @escaping () -> Bool = true,
        decodeWhen shouldDecode: @autoclosure @escaping () -> Bool = true
    ) throws {
        
        let codingKey = DynamicKey(stringValue: key)
        
        if var container = encodingContainer {
            if shouldEncode() {
                try container.encode(value(), forKey: codingKey)
                if !shouldDecode() {
                    readOnlyFields.append(key)
                }
            }
        }
        
        if let container = decodingContainer {
            if shouldDecode() {
                do {
                    let nextValue = try container.decode(Type.self, forKey: codingKey)
                    try decoder(nextValue)
                } catch DecodingError.keyNotFound(_, _) {}
            }
        }
    }
    
    public func readOnly<Type: Encodable>(
        _ key: String,
        _ value: @autoclosure () throws -> Type?,
        encodeWhen shouldEncode: @autoclosure @escaping () -> Bool = true
        ) throws {
        
        let codingKey = DynamicKey(stringValue: key)
        
        if var container = encodingContainer {
            if shouldEncode() {
                try container.encode(value(), forKey: codingKey)
            }
        }
    }
    
    public func writeOnly<Type: Decodable>(
        _ key: String,
        _ decoder: @escaping (Type) throws -> Void,
        decodeWhen shouldDecode: @autoclosure @escaping () -> Bool = true
        ) throws {
        
        let codingKey = DynamicKey(stringValue: key)
        
        if let container = decodingContainer {
            if shouldDecode() {
                do {
                    let nextValue = try container.decode(Type.self, forKey: codingKey)
                    try decoder(nextValue)
                } catch DecodingError.keyNotFound(_, _) {}
            }
        }
    }
    
    // MARK: KeyPath conveniences
    
    public func field<Type: Codable>(
        _ key: String,
        _ path: WritableKeyPath<S.Model,Type>,
        encodeWhen shouldEncode: @autoclosure @escaping () -> Bool = true,
        decodeWhen shouldDecode: @autoclosure @escaping () -> Bool = true
    ) throws {
        try self.field(
            key,
            serializer.model[keyPath: path],
            { self.serializer.model[keyPath: path] = $0 },
            encodeWhen: shouldEncode,
            decodeWhen: shouldDecode
        )
    }
    
    public func readOnly<Type: Encodable>(
        _ key: String,
        _ path: KeyPath<S.Model,Type>,
        encodeWhen shouldEncode: @autoclosure @escaping () -> Bool = true
        ) throws {
        try self.readOnly(
            key,
            serializer.model[keyPath: path],
            encodeWhen: shouldEncode
        )
    }
    
    public func writeOnly<Type: Decodable>(
        _ key: String,
        _ path: WritableKeyPath<S.Model,Type>,
        decodeWhen shouldDecode: @autoclosure @escaping () -> Bool = true
        ) throws {
        
        try self.writeOnly(
            key,
            { self.serializer.model[keyPath: path] = $0 },
            decodeWhen: shouldDecode
        )
    }
    
    // MARK: Embedded resource methods
    
    public func embeddedResource<Type: Serializable>(
        _ key: String,
        _ value: @autoclosure () throws -> Type?,
        _ decoder: @escaping (Type) throws -> Void,
        encodeWhen shouldEncode: @autoclosure @escaping () -> Bool = true,
        decodeWhen shouldDecode: @autoclosure @escaping () -> Bool = true
        ) throws where Type.ModelSerializer: EncodeSerializer & DecodeSerializer {
        
        var serializer: Type.ModelSerializer? = nil
        if shouldEncode() {
            serializer = try value()?.makeSerializer(in: self.serializer.context)
        }
        
        try self.field(
            key,
            serializer,
            { if let v = $0.model as? Type { try decoder(v) } },
            encodeWhen: shouldEncode(),
            decodeWhen: shouldDecode()
        )
    }
    
    public func readOnlyEmbeddedResource<Type: Serializable>(
        _ key: String,
        _ value: @autoclosure () throws -> Type?,
        encodeWhen shouldEncode: @autoclosure @escaping () -> Bool = true
        ) throws where Type.ModelSerializer: EncodeSerializer & DecodeSerializer {
        
        try self.embeddedResource(
            key,
            value,
            { _ in },
            encodeWhen: shouldEncode(),
            decodeWhen: false
        )
    }
    
    public func writeOnlyEmbeddedResource<S: DecodeSerializer & EncodeSerializer>(
        _ key: String,
        _ decoder: @escaping (S.Model) throws -> Void,
        using deserializerType: S.Type,
        decodeWhen shouldDecode: @autoclosure @escaping () -> Bool = true
        ) throws {

        var deserializer = deserializerType.init()
        deserializer.context = self.serializer.context

        try self.field(
            key,
            deserializer,
            { try decoder($0.model) },
            encodeWhen: false,
            decodeWhen: shouldDecode()
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
