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
    
    func add(_ key: String, _ value: String?, _ decoder: @escaping (String) -> Void) {
        add(key, value, decoder, \.stringValue, \.stringDecode)
    }
    func add(_ key: String, _ value: Int?, _ decoder: @escaping (Int) -> Void) {
        add(key, value, decoder, \.intValue, \.intDecode)
    }
    func add(_ key: String, _ value: Bool?, _ decoder: @escaping (Bool) -> Void) {
        add(key, value, decoder, \.boolValue, \.boolDecode)
    }
    
    private func add<T>(
        _ key: String,
        _ value: T?,
        _ decoder: @escaping (T) -> Void,
        _ valueKP: WritableKeyPath<Field,T?>,
        _ decodeKP: WritableKeyPath<Field,((T)->Void)?>) {
        
        var field = Field(key: key)
        field[keyPath: valueKP] = value
        field[keyPath: decodeKP] = decoder
        fields.append(field)
    }
    
    
    func add(_ key: String, _ path: WritableKeyPath<M,String>) {
        addForKeyPath(key, path, \.stringValue, \.stringDecode)
    }
    func add(_ key: String, _ path: WritableKeyPath<M,Int>) {
        addForKeyPath(key, path, \.intValue, \.intDecode)
    }
    func add(_ key: String, _ path: WritableKeyPath<M,Int?>) {
        addForKeyPathOptional(key, path, \.intValue, \.intDecodeOptional)
    }
    func add(_ key: String, _ path: WritableKeyPath<M,Bool>) {
        addForKeyPath(key, path, \.boolValue, \.boolDecode)
    }
    func add(_ key: String, _ path: WritableKeyPath<M,Date>) {
        addForKeyPath(key, path, \.dateValue, \.dateDecode)
    }
    func add(_ key: String, _ path: WritableKeyPath<M,Date?>) {
        addForKeyPathOptional(key, path, \.dateValue, \.dateDecodeOptional)
    }
    
    private func addForKeyPath<T>(
        _ key: String,
        _ path: WritableKeyPath<M,T>,
        _ valueKP: WritableKeyPath<Field,T?>,
        _ decodeKP: WritableKeyPath<Field,((T)->Void)?>) {
        
        var field = Field(key: key)
        field[keyPath: valueKP] = model[keyPath: path]
        field[keyPath: decodeKP] = { self.model[keyPath: path] = $0 }
        field.referencingInternalModel = true
        fields.append(field)
    }
    
    private func addForKeyPathOptional<T>(
        _ key: String,
        _ path: WritableKeyPath<M,T>,
        _ valueKP: WritableKeyPath<Field,T>,
        _ decodeKP: WritableKeyPath<Field,((T)->Void)?>) {
        
        var field = Field(key: key)
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
