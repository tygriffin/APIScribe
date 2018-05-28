//
//  ArraySerializer.swift
//  Serialization
//
//  Created by Taylor Griffin on 28/5/18.
//

/**
 Abstraction for serializing a collection of Serializables.
 */
public struct ArraySerializer: Encodable {
    public var serializers: [BaseSerializer]
    
    public func encode(to encoder: Encoder) throws {
        var store = Store()
        
        for serializer in serializers {
            store.gather(serializer: serializer)
        }
        
        try store.encode(to: encoder)
    }
}

extension Array where Element: Serializable {
    public func makeSerializer(in context: Context? = nil) throws -> ArraySerializer {
        return ArraySerializer(serializers: self.map { $0.makeSerializer(in: context) })
    }
}

