//
//  Storable.swift
//  Serialization
//
//  Created by Taylor Griffin on 12/5/18.
//

protocol Storable : Encodable {
    static var type: StorableType { get }
}

struct DynamicKey : CodingKey {
    var stringValue: String
    init?(stringValue: String) {
        self.stringValue = stringValue
    }
    var intValue: Int? { return nil }
    init?(intValue: Int) { return nil }
}

enum StorableType : String, Codable {
    case certificateBundle, creation
    
    // TODO: Do I need this?
//    var metatype: Storable.Type {
//        switch self {
//        case .certificateBundle: return CertificateBundleSerializer.self
//        }
//    }
}

struct AnyStorable : Encodable {
    var base: Storable
    
    init(_ base: Storable) {
        self.base = base
    }
    
    func encode(to encoder: Encoder) throws {
        try base.encode(to: encoder)
    }
}
