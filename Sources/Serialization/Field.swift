//
//  Field.swift
//  Serialization
//
//  Created by Taylor Griffin on 12/5/18.
//

struct Field : Encodable {
    var key: String
    
    var stringValue: String?
    var stringDecode: ((String) -> Void)?
    var intValue: Int?
    var intDecode: ((Int) -> Void)?
    
    var shouldEncode = true
    
    init(key: String) {
        self.key = key
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let v = stringValue { try container.encode(v) }
        if let v = intValue { try container.encode(v) }
    }
}
