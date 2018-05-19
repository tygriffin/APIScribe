//
//  Serializer.swift
//  Serialization
//
//  Created by Taylor Griffin on 12/5/18.
//

class FieldBuilder<M> {
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

struct SideLoadedResourceBuilder {
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


protocol Serializer : Storable {
    
    var storeKey: String { get }
    var storeId: String { get }
    
    init()
    
    func sideLoadResources(builder: inout SideLoadedResourceBuilder)
    func makeSerialization() -> Serialization
}


protocol ModelSerializer : Serializer {
    associatedtype Model
    var model: Model { get }
    func makeFields(builder: inout FieldBuilder<Model>)
}

extension ModelSerializer {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicKey.self)
        var builder = FieldBuilder<Model>(model: model)
        makeFields(builder: &builder)
        for field in builder.fields {
            try container.encode(field, forKey: DynamicKey(stringValue: field.key)!)
        }
    }
}


extension Serializer {
    
    func makeSerialization() -> Serialization {
        return Serialization(topSerializer: self)
    }
    
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: DynamicKey.self)
//        var builder = FieldBuilder()
//        makeFields(builder: &builder)
//        for field in builder.fields {
//            try container.encode(field, forKey: DynamicKey(stringValue: field.key)!)
//        }
//    }
    
    var storeKey: String {
        return Self.type.rawValue
    }
    
    func sideLoadResources(builder: inout SideLoadedResourceBuilder) {}
}
