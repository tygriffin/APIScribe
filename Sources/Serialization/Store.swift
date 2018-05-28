//
//  Store.swift
//  Serialization
//
//  Created by Taylor Griffin on 13/5/18.
//

typealias Store = [String: [String: Storable]]

extension Dictionary where Key == String, Value == [String: Storable] {
    
    func isAlreadySerialized(key: String, id: String) -> Bool {
        return self.contains { k, v in
            return k == key && v.contains(where: { _k, _ in _k == id })
        }
    }
    
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
    
    mutating func gather(serializer: BaseSerializer) {
        self.add(storable: serializer)
        
        var builder = SideLoadedResourceBuilder()
        serializer.sideLoadResources(builder: &builder)
        
        for resource in builder.resources {
            // TODO: Alternatively, pass in a serializer here to use instead of default
            let resourceSerializer = resource.value.internalSerializer()
            if !self.isAlreadySerialized(key: resourceSerializer.storeKey, id: resourceSerializer.storeIdString) {
                self.gather(serializer: resourceSerializer)
            }
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicKey.self)
        
        for (name, dict) in self {
            var nested = container.nestedContainer(keyedBy: DynamicKey.self, forKey: DynamicKey(stringValue: name))
            for (id, value) in dict {
                try nested.encode(AnyStorable(value), forKey: DynamicKey(stringValue: id))
            }
        }
    }
}
