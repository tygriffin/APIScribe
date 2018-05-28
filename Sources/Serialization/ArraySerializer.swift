//
//  ArraySerializer.swift
//  Serialization
//
//  Created by Taylor Griffin on 28/5/18.
//

public struct ArraySerializer: Encodable {
    var serializers: [BaseSerializer]
    
    public func encode(to encoder: Encoder) throws {
        var store = Store()
        
        for serializer in serializers {
            store.gather(serializer: serializer)
        }
        
        try store.encode(to: encoder)
    }
}

extension Array where Element: BaseSerializer {
    public func makeSerializer() throws -> ArraySerializer {
        return ArraySerializer(serializers: self)
    }
}

