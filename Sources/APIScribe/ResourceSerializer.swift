//
//  ResourceSerializer.swift
//  APIScribe
//
//  Created by Taylor Griffin on 8/7/18.
//

public protocol ResourceSerializer : ContextHolder, Storable, ModelIdentifiable {
    init()
    func sideLoadResources(builder: inout SideLoadedResourceBuilder) throws
}

extension ResourceSerializer {
    
    // Side loading resources is optional
    public func sideLoadResources(builder: inout SideLoadedResourceBuilder) throws {}
    
}

