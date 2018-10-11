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
        _ value: @autoclosure () throws -> Type,
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
        
        try coerceDecode(decoder, codingKey: codingKey, decodeWhen: shouldDecode)
        
    }
    
    public func readOnly<Type: Encodable>(
        _ key: String,
        _ value: @autoclosure () throws -> Type,
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
        
        try coerceDecode(decoder, codingKey: codingKey, decodeWhen: shouldDecode)
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
        
        try self.field(
            key,
            try value()?.makeSerializer(in: self.serializer.context),
            { if let v = $0?.model as? Type { try decoder(v) } },
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
    
    private func coerceDecode<Type: Decodable>(
        _ decoder: @escaping (Type) throws -> Void,
        codingKey: DynamicKey,
        decodeWhen shouldDecode: @autoclosure @escaping () -> Bool = true
        ) throws {
        
        if let container = decodingContainer {
            if shouldDecode() {
                do {
                    let nextValue = try container.decode(Type.self, forKey: codingKey)
                    try decoder(nextValue)
                } catch DecodingError.keyNotFound(let x, _) {
                    print(x)
                    // Always accept a partial incoming model
                } catch DecodingError.valueNotFound(let type, let context) {
                    // If value was not found because the target is non-optional and
                    // the incoming value is null, we can interpret the behavior based
                    // on the target data type. However, if the incoming value is not
                    // null, rethrow.
                    guard try container.decodeNil(forKey: codingKey) else {
                        throw DecodingError.valueNotFound(type, context)
                    }
                    
                    // Emptying a string means decoding to ""
                    if Type.self == String.self {
                        try decoder("" as! Type)
                    }
                    // Emptying a number-like type means decoding to 0
                    else if
                        Type.self == Double.self ||
                            Type.self == Float.self ||
                            Type.self == Int.self ||
                            Type.self == Int8.self ||
                            Type.self == Int16.self ||
                            Type.self == Int32.self ||
                            Type.self == Int64.self ||
                            Type.self == UInt.self ||
                            Type.self == UInt8.self ||
                            Type.self == UInt16.self ||
                            Type.self == UInt32.self ||
                            Type.self == UInt64.self {
                        
                        try decoder(0 as! Type)
                    }
                    
                    // All other target data types simply ignore the incoming
                    // null
                }
            }
        }
    }
}

/**
 Convenient abstraction for adding Resources.
 */
public struct SideLoadedResourceBuilder {
    var resources: [Resource] = []
    
    mutating public func add(resource: SerializerProducer) {
        resources.append(Resource(resource: resource))
    }
    
    mutating public func add(resource: SerializerProducer?) {
        if let resource = resource {
            self.add(resource: resource)
        }
    }
    
    mutating public func add(resources: [SerializerProducer]) {
        for resource in resources {
            self.add(resource: resource)
        }
    }
    
//    mutating public func add(resourceSerializer: ResourceSerializer) {
//        resources.append(Resource)
//    }
//    
//    mutating public func add(_ resource: SerializerProducer?) {
//        if let resource = resource {
//            self.add(resource)
//        }
//    }
//    
//    mutating public func add(_ _resources: [SerializerProducer]) {
//        for resource in _resources {
//            self.add(resource)
//        }
//    }
}
