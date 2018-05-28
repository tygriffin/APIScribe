//
//  Resource.swift
//  Serialization
//
//  Created by Taylor Griffin on 19/5/18.
//

/**
 A resource related to the primary model that should also
 be included in the output Store.
 */
struct Resource {
    var value: CanMakeSerializer
    
    var shouldEncode = true
    
    init(_ value: CanMakeSerializer) {
        self.value = value
    }
}
