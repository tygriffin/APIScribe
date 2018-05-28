//
//  Store.swift
//  Serialization
//
//  Created by Taylor Griffin on 13/5/18.
//

/**
 Normalized dictionary of serialized models with a depth of at least 3.
 First level: model namespace (for example, when serializing a collection of pets, the key would be "pets")
 Second level: model identifier (a unique primary key used to ensure models are not double serialized)
 Third level: the model to be serialized
 */
typealias Store = [String: [String: Storable]]

extension Dictionary where Key == String, Value == [String: Storable] {
    
    /**
     - Parameters:
     - key: model namespace
     - id: primary key of model
     */
    func isAlreadySerialized(key: String, id: String) -> Bool {
        return self.contains { k, v in
            return k == key && v.contains(where: { _k, _ in _k == id })
        }
    }
    
    /**
     - Parameters:
     - storable: model to be serialized
     - Note: Adds the model regardless of whether it has already been added
     */
    mutating func add(storable: Storable) {
        
        if self.index(forKey: storable.storeKey) == nil {
            var dict = Dictionary<String, Storable>()
            dict[storable.storeIdString] = storable
            self[storable.storeKey] = dict
        }
        else {
            self[storable.storeKey]?[storable.storeIdString] = storable
        }
    }
    
    /**
     Adds given serializer's model and side-loaded resources to the Store,
     unless already added.
     */
    mutating func gather(serializer: BaseSerializer) {
        self.add(storable: serializer)
        
        var builder = SideLoadedResourceBuilder()
        serializer.sideLoadResources(builder: &builder)
        
        for resource in builder.resources {
            // TODO: Alternatively, pass in a serializer here to use instead of default
            let resourceSerializer = resource.value.internalSerializer()
            
            if !self.isAlreadySerialized(
                key: resourceSerializer.storeKey,
                id: resourceSerializer.storeIdString
            ) {
                self.gather(serializer: resourceSerializer)
            }
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicKey.self)
        
        for (name, dict) in self {
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
