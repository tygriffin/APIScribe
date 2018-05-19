//
//  Resource.swift
//  Serialization
//
//  Created by Taylor Griffin on 19/5/18.
//

struct Resource {
    var value: CanMakeSerializer
    
    var shouldEncode = true
    
    init(_ value: CanMakeSerializer) {
        self.value = value
    }
}
