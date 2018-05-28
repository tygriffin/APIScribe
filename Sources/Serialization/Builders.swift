//
//  Builders.swift
//  Serialization
//
//  Created by Taylor Griffin on 19/5/18.
//

import Foundation

/**
 Convenient abstraction for building up Fields.
 - Note: When adding support for additional data-types, this class must
 be extended.
 */
public class FieldBuilder<M> {
    var fields: [Field] = []
    var model: M
    
    init(model: M) {
        self.model = model
    }
    
    // Base
    //
    
    // String
    public func add(_ key: String, _ value: String?, _ decoder: @escaping (String) -> Void, shouldEncode: @autoclosure @escaping () -> Bool = true, shouldDecode: @autoclosure @escaping () -> Bool = true) {
        add(key, value, decoder, \.stringValue, \.stringDecode, shouldEncode, shouldDecode)
    }
    // Int
    public func add(_ key: String, _ value: Int?, _ decoder: @escaping (Int) -> Void, shouldEncode: @autoclosure @escaping () -> Bool = true, shouldDecode: @autoclosure @escaping () -> Bool = true) {
        add(key, value, decoder, \.intValue, \.intDecode, shouldEncode, shouldDecode)
    }
    // Decimal
    public func add(_ key: String, _ value: Decimal?, _ decoder: @escaping (Decimal) -> Void, shouldEncode: @autoclosure @escaping () -> Bool = true, shouldDecode: @autoclosure @escaping () -> Bool = true) {
        add(key, value, decoder, \.decimalValue, \.decimalDecode, shouldEncode, shouldDecode)
    }
    // Double
    public func add(_ key: String, _ value: Double?, _ decoder: @escaping (Double) -> Void, shouldEncode: @autoclosure @escaping () -> Bool = true, shouldDecode: @autoclosure @escaping () -> Bool = true) {
        add(key, value, decoder, \.doubleValue, \.doubleDecode, shouldEncode, shouldDecode)
    }
    // Bool
    public func add(_ key: String, _ value: Bool?, _ decoder: @escaping (Bool) -> Void, shouldEncode: @autoclosure @escaping () -> Bool = true, shouldDecode: @autoclosure @escaping () -> Bool = true) {
        add(key, value, decoder, \.boolValue, \.boolDecode, shouldEncode, shouldDecode)
    }
    // Date
    public func add(_ key: String, _ value: Date?, _ decoder: @escaping (Date) -> Void, shouldEncode: @autoclosure @escaping () -> Bool = true, shouldDecode: @autoclosure @escaping () -> Bool = true) {
        add(key, value, decoder, \.dateValue, \.dateDecode, shouldEncode, shouldDecode)
    }
    
    private func add<T>(
        _ key: String,
        _ value: T?,
        _ decoder: @escaping (T) -> Void,
        _ valueKP: WritableKeyPath<Field,T?>,
        _ decodeKP: WritableKeyPath<Field,((T)->Void)?>,
        _ shouldEncode: @escaping () -> Bool = { true },
        _ shouldDecode: @escaping () -> Bool = { true }) {
        
        var field = Field(key: key)
        field.shouldEncode = shouldEncode
        field.shouldDecode = shouldDecode
        field[keyPath: valueKP] = value
        field[keyPath: decodeKP] = decoder
        fields.append(field)
    }
    
    // KeyPaths
    //
    
    // String
    public func add(_ key: String, _ path: WritableKeyPath<M,String>, shouldEncode: @autoclosure @escaping () -> Bool = true, shouldDecode: @autoclosure @escaping () -> Bool = true) {
        addForKeyPath(key, path, \.stringValue, \.stringDecode, shouldEncode, shouldDecode)
    }
    public func add(_ key: String, _ path: WritableKeyPath<M,String?>, shouldEncode: @autoclosure @escaping () -> Bool = true, shouldDecode: @autoclosure @escaping () -> Bool = true) {
        addForKeyPathOptional(key, path, \.stringValue, \.stringDecodeOptional, shouldEncode, shouldDecode)
    }
    
    // Int
    public func add(_ key: String, _ path: WritableKeyPath<M,Int>, shouldEncode: @autoclosure @escaping () -> Bool = true, shouldDecode: @autoclosure @escaping () -> Bool = true) {
        addForKeyPath(key, path, \.intValue, \.intDecode, shouldEncode, shouldDecode)
    }
    public func add(_ key: String, _ path: WritableKeyPath<M,Int?>, shouldEncode: @autoclosure @escaping () -> Bool = true, shouldDecode: @autoclosure @escaping () -> Bool = true) {
        addForKeyPathOptional(key, path, \.intValue, \.intDecodeOptional, shouldEncode, shouldDecode)
    }
    
    // Decimal
    public func add(_ key: String, _ path: WritableKeyPath<M,Decimal>, shouldEncode: @autoclosure @escaping () -> Bool = true, shouldDecode: @autoclosure @escaping () -> Bool = true) {
        addForKeyPath(key, path, \.decimalValue, \.decimalDecode, shouldEncode, shouldDecode)
    }
    public func add(_ key: String, _ path: WritableKeyPath<M,Decimal?>, shouldEncode: @autoclosure @escaping () -> Bool = true, shouldDecode: @autoclosure @escaping () -> Bool = true) {
        addForKeyPathOptional(key, path, \.decimalValue, \.decimalDecodeOptional, shouldEncode, shouldDecode)
    }
    
    // Double
    public func add(_ key: String, _ path: WritableKeyPath<M,Double>, shouldEncode: @autoclosure @escaping () -> Bool = true, shouldDecode: @autoclosure @escaping () -> Bool = true) {
        addForKeyPath(key, path, \.doubleValue, \.doubleDecode, shouldEncode, shouldDecode)
    }
    public func add(_ key: String, _ path: WritableKeyPath<M,Double?>, shouldEncode: @autoclosure @escaping () -> Bool = true, shouldDecode: @autoclosure @escaping () -> Bool = true) {
        addForKeyPathOptional(key, path, \.doubleValue, \.doubleDecodeOptional, shouldEncode, shouldDecode)
    }
    
    // Bool
    public func add(_ key: String, _ path: WritableKeyPath<M,Bool>, shouldEncode: @autoclosure @escaping () -> Bool = true, shouldDecode: @autoclosure @escaping () -> Bool = true) {
        addForKeyPath(key, path, \.boolValue, \.boolDecode, shouldEncode, shouldDecode)
    }
    public func add(_ key: String, _ path: WritableKeyPath<M,Bool?>, shouldEncode: @autoclosure @escaping () -> Bool = true, shouldDecode: @autoclosure @escaping () -> Bool = true) {
        addForKeyPathOptional(key, path, \.boolValue, \.boolDecodeOptional, shouldEncode, shouldDecode)
    }
    
    // Date
    public func add(_ key: String, _ path: WritableKeyPath<M,Date>, shouldEncode: @autoclosure @escaping () -> Bool = true, shouldDecode: @autoclosure @escaping () -> Bool = true) {
        addForKeyPath(key, path, \.dateValue, \.dateDecode, shouldEncode, shouldDecode)
    }
    public func add(_ key: String, _ path: WritableKeyPath<M,Date?>, shouldEncode: @autoclosure @escaping () -> Bool = true, shouldDecode: @autoclosure @escaping () -> Bool = true) {
        addForKeyPathOptional(key, path, \.dateValue, \.dateDecodeOptional, shouldEncode, shouldDecode)
    }
    
    private func addForKeyPath<T>(
        _ key: String,
        _ path: WritableKeyPath<M,T>,
        _ valueKP: WritableKeyPath<Field,T?>,
        _ decodeKP: WritableKeyPath<Field,((T)->Void)?>,
        _ shouldEncode: @escaping () -> Bool = { true },
        _ shouldDecode: @escaping () -> Bool = { true }) {
        
        var field = Field(key: key)
        field.shouldEncode = shouldEncode
        field.shouldDecode = shouldDecode
        field[keyPath: valueKP] = model[keyPath: path]
        field[keyPath: decodeKP] = { self.model[keyPath: path] = $0 }
        field.referencingInternalModel = true
        fields.append(field)
    }
    
    private func addForKeyPathOptional<T>(
        _ key: String,
        _ path: WritableKeyPath<M,T>,
        _ valueKP: WritableKeyPath<Field,T>,
        _ decodeKP: WritableKeyPath<Field,((T)->Void)?>,
        _ shouldEncode: @escaping () -> Bool = { true },
        _ shouldDecode: @escaping () -> Bool = { true }) {
        
        var field = Field(key: key)
        field.shouldEncode = shouldEncode
        field.shouldDecode = shouldDecode
        field[keyPath: valueKP] = model[keyPath: path]
        field[keyPath: decodeKP] = { self.model[keyPath: path] = $0 }
        field.referencingInternalModel = true
        fields.append(field)
    }
}

/**
 Convenient abstraction for adding Resources.
 */
public struct SideLoadedResourceBuilder {
    var resources: [Resource] = []
    
    mutating public func add(_ resource: CanMakeSerializer) {
        resources.append(Resource(resource))
    }
    
    mutating public func add(_ _resources: [CanMakeSerializer]) {
        for resource in _resources {
            resources.append(Resource(resource))
        }
    }
}
