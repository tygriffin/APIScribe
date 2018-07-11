//
//  Storable.swift
//  APIScribe
//
//  Created by Taylor Griffin on 12/5/18.
//

/**
 Storables are leafs in the Store.
 */
public protocol Storable : Encodable {
    static var type: String { get }
    var storeKey: String { get }
    var storeIdString: String { get }
}

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
