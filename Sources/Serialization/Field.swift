//
//  Field.swift
//  Serialization
//
//  Created by Taylor Griffin on 12/5/18.
//

import Foundation

/**
 Struct to hold the actual encodable value and the decoding instructions,
 as well as closures that determine if encoding / decoding should take place.
 If more data types are to be supported, then storage must be added to this struct.
 */
struct Field : Encodable {
    var key: String
    
    // String
    var stringValue: String?
    var stringDecode: ((String) -> Void)?
    var stringDecodeOptional: ((String?) -> Void)?
    // Int
    var intValue: Int?
    var intDecode: ((Int) -> Void)?
    var intDecodeOptional: ((Int?) -> Void)?
    // Decimal
    var decimalValue: Decimal?
    var decimalDecode: ((Decimal) -> Void)?
    var decimalDecodeOptional: ((Decimal?) -> Void)?
    // Double
    var doubleValue: Double?
    var doubleDecode: ((Double) -> Void)?
    var doubleDecodeOptional: ((Double?) -> Void)?
    // Bool
    var boolValue: Bool?
    var boolDecode: ((Bool) -> Void)?
    var boolDecodeOptional: ((Bool?) -> Void)?
    // Date
    var dateValue: Date?
    var dateDecode: ((Date) -> Void)?
    var dateDecodeOptional: ((Date?) -> Void)?
    
    var shouldEncode: () -> Bool = { true }
    var shouldDecode: () -> Bool = { true }
    
    /// An internal flag that signals whether the model should copied back up
    /// to the deserializer or back down the builder.
    var referencingInternalModel = false
    
    init(key: String) {
        self.key = key
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let v = stringValue { try container.encode(v); return }
        if let v = intValue { try container.encode(v); return }
        if let v = decimalValue { try container.encode(v); return }
        if let v = doubleValue { try container.encode(v); return }
        if let v = boolValue { try container.encode(v); return }
        if let v = dateValue { try container.encode(v); return }
        
        try container.encodeNil()
    }
}
