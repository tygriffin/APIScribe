//
//  Builders.swift
//  Serialization
//
//  Created by Taylor Griffin on 19/5/18.
//

public class FieldBuilder<M> {
    var fields: [Field] = []
    var model: M
    
    init(model: M) {
        self.model = model
    }
    
    func add(_ key: String, _ value: String, _ decoder: @escaping (String) -> Void) {
        var field = Field(key: key)
        field.stringValue = value
        field.stringDecode = decoder
        fields.append(field)
    }
    func add(_ key: String, _ value: Int, _ decoder: @escaping (Int) -> Void) {
        var field = Field(key: key)
        field.intValue = value
        field.intDecode = decoder
        fields.append(field)
    }
    
    func add(_ key: String, _ path: WritableKeyPath<M,String>) {
        add(key, model[keyPath: path], { self.model[keyPath: path] = $0 })
    }
    func add(_ key: String, _ path: WritableKeyPath<M,Int>) {
        add(key, model[keyPath: path], { self.model[keyPath: path] = $0 })
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
