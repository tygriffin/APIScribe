//
//  Store.swift
//  Serialization
//
//  Created by Taylor Griffin on 13/5/18.
//

typealias Store = [String: [String: Storable]]

extension Dictionary where Key == String, Value == [String: Storable] {
    
    func isAlreadySerialized(key: String, id: String) -> Bool {
        return self.contains { k, v in
            return k == key && v.contains(where: { _k, _ in _k == id })
        }
    }
}
