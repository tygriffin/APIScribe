//
//  Serializable.swift
//  Serialization
//
//  Created by Taylor Griffin on 13/5/18.
//

public protocol CanMakeSerializer {
    func internalSerializer() -> BaseSerializer
}

public protocol Serializable : CanMakeSerializer {
    associatedtype ModelSerializer: BaseSerializer
    
    func makeSerializer() -> ModelSerializer
}

extension Serializable {
    public func internalSerializer() -> BaseSerializer {
        return makeSerializer()
    }
}
