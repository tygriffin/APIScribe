//
//  Serialization.swift
//  Serialization
//
//  Created by Taylor Griffin on 13/5/18.
//

public class Serialization : Encodable {
    
    init(topSerializer: InternalSerializer) {
        self.topSerializer = topSerializer
    }
    
    var topSerializer: InternalSerializer
    
    var store: Store = [:]
    
    public func encode(to encoder: Encoder) throws {
        
        gather(serializer: topSerializer)
        
        var container = encoder.container(keyedBy: DynamicKey.self)

        for (name, dict) in store {
            var nested = container.nestedContainer(keyedBy: DynamicKey.self, forKey: DynamicKey(stringValue: name)!)
            for (id, value) in dict {
                try nested.encode(AnyStorable(value), forKey: DynamicKey(stringValue: id)!)
            }
        }
    }
    
    private func gather(serializer: InternalSerializer) {
        store.add(storable: serializer)
        
        var builder = SideLoadedResourceBuilder()
        serializer.sideLoadResources(builder: &builder)
        for resource in builder.resources {
            // TODO: Alternatively, pass in a serializer here to use instead of default
            let resourceSerializer = resource.value.internalSerializer()
            if !store.isAlreadySerialized(key: resourceSerializer.storeKey, id: resourceSerializer.storeIdString) {
                gather(serializer: resourceSerializer)
            }
        }
    }
}
