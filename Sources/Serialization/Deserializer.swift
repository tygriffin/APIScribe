//
//  Deserializer.swift
//  Serialization
//
//  Created by Taylor Griffin on 19/5/18.
//

protocol Deserializer : Decodable {
    associatedtype Model
    var model: Model { get }
    func makeFields(builder: inout FieldBuilder)
    init()
}

extension Deserializer {
    init(from decoder: Decoder) throws {
        self.init()
        
        let container = try decoder.container(keyedBy: DynamicKey.self)
        
        var builder = FieldBuilder()
        makeFields(builder: &builder)
        for field in builder.fields {
            if let d = field.stringDecode {
                d(try container.decode(String.self, forKey: DynamicKey(stringValue: field.key)!))
            }
            if let d = field.intDecode {
                d(try container.decode(Int.self, forKey: DynamicKey(stringValue: field.key)!))
            }
        }
    }
}
