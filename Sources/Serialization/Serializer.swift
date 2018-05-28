//
//  Serializer.swift
//  Serialization
//
//  Created by Taylor Griffin on 12/5/18.
//

public protocol Serializer : BaseSerializer {
    associatedtype Model
    var model: Model { get set }
    var storeId: KeyPath<Model, String> { get }
    func makeFields(builder: inout FieldBuilder<Model>)
    init(model: Model)
}

extension Serializer {
    
    public init(model: Model) {
        self.init()
        self.model = model
    }
    
    public func encode(to encoder: Encoder) throws {
        if encoder.codingPath.isEmpty {
            try encodeAsPrimary(to: encoder)
        }
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
    
    init()
    
    func sideLoadResources(builder: inout SideLoadedResourceBuilder)
}

extension BaseSerializer {
    
    public var storeKey: String {
        return Self.type
    }
    
    public func sideLoadResources(builder: inout SideLoadedResourceBuilder) {}
}
