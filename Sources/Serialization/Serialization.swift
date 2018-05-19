
class Serialization : Encodable {
    
    init(topSerializer: Serializer) {
        self.topSerializer = topSerializer
    }
    
    var topSerializer: Serializer
    
    var store: Store = [:]
    
    func encode(to encoder: Encoder) throws {
        
        gather(serializer: topSerializer)
        
        var container = encoder.container(keyedBy: DynamicKey.self)

        for (name, dict) in store {
            var nested = container.nestedContainer(keyedBy: DynamicKey.self, forKey: DynamicKey(stringValue: name)!)
            for (id, value) in dict {
                try nested.encode(AnyStorable(value), forKey: DynamicKey(stringValue: id)!)
            }
        }
    }
    
    private func gather(serializer: Serializer) {
        store.add(serializer: serializer)
        
        var builder = SideLoadedResourceBuilder()
        serializer.sideLoadResources(builder: &builder)
        for resource in builder.resources {
            // TODO: Alternatively, pass in a serializer here to use instead of default
            let resourceSerializer = resource.value.internalSerializer()
            if !store.isAlreadySerialized(key: resourceSerializer.storeKey, id: resourceSerializer.storeId) {
                gather(serializer: resourceSerializer)
            }
        }
    }
}
