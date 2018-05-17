//
//  Field.swift
//  Serialization
//
//  Created by Taylor Griffin on 12/5/18.
//

struct Field : Encodable {
    var key: String
    
    var stringValue: String?
    var intValue: Int?
    
    var shouldEncode = true
    
    init(key: String, _ value: @autoclosure () -> String) {
        self.key = key
        self.stringValue = value()
    }
    
    init(key: String, _ value: @autoclosure () -> Int) {
        self.key = key
        self.intValue = value()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let v = stringValue { try container.encode(v) }
        if let v = intValue { try container.encode(v) }
    }
}

struct Resource {
    var value: CanMakeSerializer
    
    var shouldEncode = true
    
    init(_ value: CanMakeSerializer) {
        self.value = value
    }
}
