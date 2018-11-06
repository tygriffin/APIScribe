//
//  Resource.swift
//  APIScribe
//
//  Created by Taylor Griffin on 19/5/18.
//

/**
 A resource related to the primary model that should also
 be included in the output Store.
 */
struct Resource {
    private var serializerProducer: SerializerProducer?
    private var resourceSerializer: ResourceSerializer?
    
    init(resource value: SerializerProducer) {
        self.serializerProducer = value
    }
    
    init(resourceSerializer serializer: ResourceSerializer) {
        self.resourceSerializer = serializer
    }
    
    public func serializer(in context: Context? = nil) throws -> ResourceSerializer {
        var result: ResourceSerializer?
        
        if let producer = serializerProducer {
            result = producer.internalSerializer(in: context)
        }
        if var serializer = resourceSerializer {
            serializer.context = serializer.context ?? context
            result = serializer
        }
        
        // Impossible to nil because this struct must be initialized with
        // either a SerializerProducer or ResourceSerializer.
        return result!
    }
}
