//
//  Serializer.swift
//  Serialization
//
//  Created by Taylor Griffin on 12/5/18.
//

/**
 Serializers hold instructions for serializing a model and
 its side-loaded resources, and acts as a kind of context for
 conditional serializing.
 */
public protocol Serializer : BaseSerializer {
    associatedtype Model
    
    // The model to be serialized
    var model: Model { get set }
    // The namespace for like models in the output
    var storeId: KeyPath<Model, String> { get }
    // Instructions for serialization / deserialization
    func makeFields(builder: inout FieldBuilder<Model>)
    
    init(model: Model, in context: Context?)
}

extension Serializer {
    
    public init(model: Model, in context: Context? = nil) {
        self.init()
        self.model = model
        self.context = context
    }
    
    public func encode(to encoder: Encoder) throws {
        // When the coding path is empty this is top ("primary") node...
        if encoder.codingPath.isEmpty {
            try encodeAsPrimary(to: encoder)
        }
        // ... otherwise, this is a leaf in a serialization started by another serializer.
        else {
            try encodeAsLeaf(to: encoder)
        }
    }
    
    private func encodeAsPrimary(to encoder: Encoder) throws {
        var store = Store()
        store.gather(serializer: self)
        try store.encode(to: encoder)
    }
    
    private func encodeAsLeaf(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicKey.self)
        var builder = FieldBuilder<Model>(model: model)
        makeFields(builder: &builder)
        for field in builder.fields {
            if field.shouldEncode() {
                try container.encode(field, forKey: DynamicKey(stringValue: field.key))
            }
        }
    }
    
    public var storeIdString: String {
        return model[keyPath: storeId]
    }
}

public protocol BaseSerializer : Storable {
    
    var context: Context? { get set }
    init()
    func sideLoadResources(builder: inout SideLoadedResourceBuilder)
}

extension BaseSerializer {
    
    public var storeKey: String {
        return Self.type
    }
    
    // Side loading resources is optional
    public func sideLoadResources(builder: inout SideLoadedResourceBuilder) {}
}
