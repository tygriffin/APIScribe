//
//  Field.swift
//  Serialization
//
//  Created by Taylor Griffin on 12/5/18.
//

import Foundation

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
    var boolDecodeOptional: ((Bool) -> Void)?
    // Date
    var dateValue: Date?
    var dateDecode: ((Date) -> Void)?
    var dateDecodeOptional: ((Date?) -> Void)?
    
    var shouldEncode: () -> Bool = { true }
    var shouldDecode: () -> Bool = { true }
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
