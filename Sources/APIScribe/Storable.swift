//
//  Storable.swift
//  APIScribe
//
//  Created by Taylor Griffin on 12/5/18.
//

public protocol StoreKeyIdentifiable {
    static var storeKey: String { get }
    var storeKey: String { get }
}

extension StoreKeyIdentifiable {
    public var storeKey: String {
        return Self.storeKey
    }
}

public protocol StoreIdIdentifiable {
    var storeId: String { get }
}

/**
 Storables are leafs in the Store.
 */
public protocol Storable : Encodable, StoreKeyIdentifiable, StoreIdIdentifiable {}

/**
 Type-erased Storable.
 */
struct AnyStorable : Encodable {
    var base: Storable
    
    init(_ base: Storable) {
        self.base = base
    }
    
    func encode(to encoder: Encoder) throws {
        try base.encode(to: encoder)
    }
}

