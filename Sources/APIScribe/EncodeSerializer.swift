//
//  Serializer.swift
//  APIScribe
//
//  Created by Taylor Griffin on 12/5/18.
//

/**
 Serializers hold instructions for serializing a model and
 its side-loaded resources, and acts as a kind of context for
 conditional serializing.
 */
public protocol EncodeSerializer : ResourceSerializer, FieldMaker {
    init(model: Model, in context: Context?)
}

extension EncodeSerializer {
    
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
        store.primary = self
        try store.gather(serializer: self)
        try store.encode(to: encoder)
    }
    
    private func encodeAsLeaf(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicKey.self)
        var builder = FieldBuilder<Self>(modelHolder: self)
        builder.encodingContainer = container
        try makeFields(builder: &builder)
        try container.encode(builder.readOnlyFields, forKey: DynamicKey(stringValue: "_readOnly"))
    }
    
    public var storeId: String {
        return model.storeId
    }
}
