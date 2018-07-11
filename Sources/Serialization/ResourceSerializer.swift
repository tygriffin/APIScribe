//
//  ResourceSerializer.swift
//  Serialization
//
//  Created by Taylor Griffin on 8/7/18.
//

public protocol ResourceSerializer : Storable, ContextHolder {
    init()
    func sideLoadResources(builder: inout SideLoadedResourceBuilder)
}

extension ResourceSerializer {
    
    public var storeKey: String {
        return Self.type
    }
    
    // Side loading resources is optional
    public func sideLoadResources(builder: inout SideLoadedResourceBuilder) {}
}

