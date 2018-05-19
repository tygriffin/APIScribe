//
//  Serializer.swift
//  Serialization
//
//  Created by Taylor Griffin on 12/5/18.
//

struct FieldBuilder {
    var fields: [Field] = []
    
    mutating func add(_ key: String, _ value: String) {
        fields.append(Field(key: key, value))
    }
    mutating func add(_ key: String, _ value: Int) {
        fields.append(Field(key: key, value))
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
    
    func makeFields(builder: inout FieldBuilder)
    func sideLoadResources(builder: inout SideLoadedResourceBuilder)
    func makeSerialization() -> Serialization
}



extension Serializer {
    
    func makeSerialization() -> Serialization {
        return Serialization(topSerializer: self)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicKey.self)
        var builder = FieldBuilder()
        makeFields(builder: &builder)
        for field in builder.fields {
            try container.encode(field, forKey: DynamicKey(stringValue: field.key)!)
        }
    }
    
    var storeKey: String {
        return Self.type.rawValue
    }
    
    func sideLoadResources(builder: inout SideLoadedResourceBuilder) {}
}
