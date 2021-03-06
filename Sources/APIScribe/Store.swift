//
//  Store.swift
//  APIScribe
//
//  Created by Taylor Griffin on 13/5/18.
//

/**
 Normalized dictionary of serialized models with a depth of at least 3.
 First level: model namespace (for example, when serializing a collection of pets, the key would be "pets")
 Second level: model identifier (a unique primary key used to ensure models are not double serialized)
 Third level: the model to be serialized
 */
typealias Storage = [String: [String: Storable]]

struct Store {
    
    var primary: (StoreIdIdentifiable & StoreKeyIdentifiable)?
    var storage: Storage = [:]
    
    /**
     - Parameters:
     - key: model namespace
     - id: primary key of model
     */
    func isAlreadySerialized(key: String, id: String) -> Bool {
        return storage.contains { k, v in
            return k == key && v.contains(where: { _k, _ in _k == id })
        }
    }
    
    /**
     - Parameters:
     - storable: model to be serialized
     - Note: Adds the model regardless of whether it has already been added
     */
    mutating func add(storable: Storable) {
        
        if storage.index(forKey: storable.storeKey) == nil {
            var dict = Dictionary<String, Storable>()
            dict[storable.storeId] = storable
            storage[storable.storeKey] = dict
        }
        else {
            storage[storable.storeKey]?[storable.storeId] = storable
        }
    }
    
    /**
     Adds given serializer's model and side-loaded resources to the Store,
     unless already added.
     */
    mutating func gather(serializer: ResourceSerializer) throws {
        self.add(storable: serializer)
        
        var builder = SideLoadedResourceBuilder()
        try serializer.sideLoadResources(builder: &builder)
        
        for resource in builder.resources {
            let resourceSerializer = try resource.serializer(in: serializer.context)
            
            if !self.isAlreadySerialized(
                key: resourceSerializer.storeKey,
                id: resourceSerializer.storeId
                ) {
                try self.gather(serializer: resourceSerializer)
            }
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicKey.self)
        
        if let primary = primary {
            try container.encode(
                [primary.storeKey, primary.storeId],
                forKey: DynamicKey(stringValue: "_primary")
            )
        }
        
        for (name, dict) in storage {
            var nested = container.nestedContainer(
                keyedBy: DynamicKey.self,
                forKey: DynamicKey(stringValue: name)
            )
            for (id, value) in dict {
                try nested.encode(
                    AnyStorable(value),
                    forKey: DynamicKey(stringValue: id)
                )
            }
        }
    }
}
