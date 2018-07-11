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
    var value: SerializerProducer
    
    var shouldEncode = true
    
    init(_ value: SerializerProducer) {
        self.value = value
    }
}
