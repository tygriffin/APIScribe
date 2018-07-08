//
//  ModelHolder.swift
//  Serialization
//
//  Created by Taylor Griffin on 8/7/18.
//

public protocol ModelHolder {
    associatedtype Model
    
    // The model to be serialized or deserialized
    var model: Model { get set }
}

