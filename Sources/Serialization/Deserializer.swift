//
//  Deserializer.swift
//  Serialization
//
//  Created by Taylor Griffin on 19/5/18.
//

public protocol Deserializer : Decodable {
    associatedtype Model
    var model: Model { get set }
    func makeFields(builder: inout FieldBuilder<Model>)
    init()
}

extension Deserializer {
    init(from decoder: Decoder) throws {
        self.init()
        
        let container = try decoder.container(keyedBy: DynamicKey.self)
        
        var builder = FieldBuilder<Model>(model: model)
        makeFields(builder: &builder)
        for field in builder.fields {
            if let d = field.stringDecode {
                if let v = try container.decodeIfPresent(String.self, forKey: DynamicKey(stringValue: field.key)!) {
                    d(v)
                }
            }
            if let d = field.intDecode {
                if let v = try container.decodeIfPresent(Int.self, forKey: DynamicKey(stringValue: field.key)!) {
                    d(v)
                }
            }
        }
        
        model = builder.model
    }
}
