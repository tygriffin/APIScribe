//
//  Serializable.swift
//  Serialization
//
//  Created by Taylor Griffin on 13/5/18.
//

protocol CanMakeSerializer {
    func internalSerializer() -> Serializer
}

protocol Serializable : CanMakeSerializer {
    associatedtype ModelSerializer: Serializer
    
    func makeSerializer() -> ModelSerializer
}

extension Serializable {
    func makeSerialization() -> Serialization {
        return Serialization(topSerializer: makeSerializer())
    }
    
    func internalSerializer() -> Serializer {
        return makeSerializer()
    }
}
