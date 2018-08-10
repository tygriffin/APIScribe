//
//  Serializable.swift
//  APIScribe
//
//  Created by Taylor Griffin on 13/5/18.
//

/**
 Protocol that exposes a subset of Serializable's API such that
 an associatedType is not needed. Generally, in order to make a model
 side-loadable, Serializable should be extended as opposed to
 CanMakeSerializer.
 */
public protocol SerializerProducer {
    func internalSerializer(in context: Context?) -> ResourceSerializer
}

/**
 Models that extend this protocol can produce a serializer, and
 hence, be serialized. These models can also be included as side-loaded
 resources on other models.
 */
public protocol Serializable : SerializerProducer, ModelIdentifiable {
    associatedtype ModelSerializer: ResourceSerializer, ModelHolder
    
    func makeSerializer(in context: Context?) -> ModelSerializer
}

extension Serializable {
    public func internalSerializer(in context: Context? = nil) -> ResourceSerializer {
        return makeSerializer(in: context)
    }
}
