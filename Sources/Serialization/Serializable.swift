//
//  Serializable.swift
//  Serialization
//
//  Created by Taylor Griffin on 13/5/18.
//

protocol CanMakeSerializer {
    func internalSerializer() -> InternalSerializer
}

protocol Serializable : CanMakeSerializer {
    associatedtype ModelSerializer: InternalSerializer
    
    func makeSerializer() -> ModelSerializer
}

extension Serializable {
    func makeSerialization() -> Serialization {
        return Serialization(topSerializer: makeSerializer())
    }
    
    func internalSerializer() -> InternalSerializer {
        return makeSerializer()
    }
}
