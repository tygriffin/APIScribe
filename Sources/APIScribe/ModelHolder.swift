//
//  ModelHolder.swift
//  APIScribe
//
//  Created by Taylor Griffin on 8/7/18.
//

public protocol ModelIdentifiable {
    var storeId: String { get }
}

public protocol ModelHolder {
    associatedtype Model: ModelIdentifiable
    
    // The model to be serialized or deserialized
    var model: Model { get set }
}

