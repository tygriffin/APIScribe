//
//  Serializer.swift
//  Serialization
//
//  Created by Taylor Griffin on 12/5/18.
//

public protocol Serializer : InternalSerializer {
    associatedtype Model
    var model: Model { get set }
    var storeId: WritableKeyPath<Model, String> { get }
    func makeFields(builder: inout FieldBuilder<Model>)
    init(model: Model)
}

extension Serializer {
    init(model: Model) {
        self.init()
        self.model = model
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicKey.self)
        var builder = FieldBuilder<Model>(model: model)
        makeFields(builder: &builder)
        for field in builder.fields {
            try container.encode(field, forKey: DynamicKey(stringValue: field.key)!)
        }
    }
    
    var storeIdString: String {
        return model[keyPath: storeId]
    }
}

public protocol InternalSerializer : Storable {
    
    var storeKey: String { get }
    var storeIdString: String { get }
    
    init()
    
    func sideLoadResources(builder: inout SideLoadedResourceBuilder)
    func makeSerialization() -> Serialization
}

extension InternalSerializer {
    
    func makeSerialization() -> Serialization {
        return Serialization(topSerializer: self)
    }
    
    var storeKey: String {
        return Self.type
    }
    
    func sideLoadResources(builder: inout SideLoadedResourceBuilder) {}
}
