//
//  Builders.swift
//  Serialization
//
//  Created by Taylor Griffin on 19/5/18.
//

import Foundation

public class FieldBuilder<M> {
    var fields: [Field] = []
    var model: M
    
    init(model: M) {
        self.model = model
    }
    
    func add(_ key: String, _ value: String?, _ decoder: @escaping (String) -> Void, shouldEncode: @autoclosure @escaping () -> Bool = true, shouldDecode: @autoclosure @escaping () -> Bool = true) {
        add(key, value, decoder, \.stringValue, \.stringDecode, shouldEncode, shouldDecode)
    }
    func add(_ key: String, _ value: Int?, _ decoder: @escaping (Int) -> Void, shouldEncode: @autoclosure @escaping () -> Bool = true, shouldDecode: @autoclosure @escaping () -> Bool = true) {
        add(key, value, decoder, \.intValue, \.intDecode, shouldEncode, shouldDecode)
    }
    func add(_ key: String, _ value: Bool?, _ decoder: @escaping (Bool) -> Void, shouldEncode: @autoclosure @escaping () -> Bool = true, shouldDecode: @autoclosure @escaping () -> Bool = true) {
        add(key, value, decoder, \.boolValue, \.boolDecode, shouldEncode, shouldDecode)
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
    
    
    func add(_ key: String, _ path: WritableKeyPath<M,String>, shouldEncode: @autoclosure @escaping () -> Bool = true, shouldDecode: @autoclosure @escaping () -> Bool = true) {
        addForKeyPath(key, path, \.stringValue, \.stringDecode, shouldEncode, shouldDecode)
    }
    func add(_ key: String, _ path: WritableKeyPath<M,Int>, shouldEncode: @autoclosure @escaping () -> Bool = true, shouldDecode: @autoclosure @escaping () -> Bool = true) {
        addForKeyPath(key, path, \.intValue, \.intDecode, shouldEncode, shouldDecode)
    }
    func add(_ key: String, _ path: WritableKeyPath<M,Int?>, shouldEncode: @autoclosure @escaping () -> Bool = true, shouldDecode: @autoclosure @escaping () -> Bool = true) {
        addForKeyPathOptional(key, path, \.intValue, \.intDecodeOptional, shouldEncode, shouldDecode)
    }
    func add(_ key: String, _ path: WritableKeyPath<M,Bool>, shouldEncode: @autoclosure @escaping () -> Bool = true, shouldDecode: @autoclosure @escaping () -> Bool = true) {
        addForKeyPath(key, path, \.boolValue, \.boolDecode, shouldEncode, shouldDecode)
    }
    func add(_ key: String, _ path: WritableKeyPath<M,Date>, shouldEncode: @autoclosure @escaping () -> Bool = true, shouldDecode: @autoclosure @escaping () -> Bool = true) {
        addForKeyPath(key, path, \.dateValue, \.dateDecode, shouldEncode, shouldDecode)
    }
    func add(_ key: String, _ path: WritableKeyPath<M,Date?>, shouldEncode: @autoclosure @escaping () -> Bool = true, shouldDecode: @autoclosure @escaping () -> Bool = true) {
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

public struct SideLoadedResourceBuilder {
    var resources: [Resource] = []
    
    mutating func add(_ resource: CanMakeSerializer) {
        resources.append(Resource(resource))
    }
    
    mutating func add(_ _resources: [CanMakeSerializer]) {
        for resource in _resources {
            resources.append(Resource(resource))
        }
    }
}
