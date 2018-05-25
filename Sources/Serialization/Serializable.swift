//
//  Serializable.swift
//  Serialization
//
//  Created by Taylor Griffin on 13/5/18.
//

public protocol CanMakeSerializer {
    func internalSerializer() -> InternalSerializer
}

public protocol Serializable : CanMakeSerializer {
    associatedtype ModelSerializer: InternalSerializer
    
    func makeSerializer() -> ModelSerializer
}

extension Serializable {
    public func makeSerialization() -> Serialization {
        return Serialization(topSerializer: makeSerializer())
    }
    
    public func internalSerializer() -> InternalSerializer {
        return makeSerializer()
    }
}
