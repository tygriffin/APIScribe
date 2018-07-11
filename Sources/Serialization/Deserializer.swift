//
//  Deserializer.swift
//  Serialization
//
//  Created by Taylor Griffin on 19/5/18.
//

import Foundation

/**
 Models implementing this protocol can use instructions in Fields
 to apply input field-by-field to the model.
 */
public protocol Deserializer : Decodable, ModelHolder, ContextHolder {

    /// Fields that contain decoding instructions
    func makeFields(builder: inout FieldBuilder<Self>) throws
    init()
}

extension Deserializer {
    
    /// Key for pulling a deserializer out of user info.
    /// Useful for when you want non-default values in the deserializer properties
    /// used during deserialization (which happens in the model's init).
    public static var deserializerInfoKey: CodingUserInfoKey? {
        return CodingUserInfoKey(rawValue: "serialization.deserializer")
    }
    
    /// Key for pulling a model out of user info.
    /// Useful for when you want to deserialize input over top of
    /// an existing model.
    public static var modelInfoKey: CodingUserInfoKey? {
        return CodingUserInfoKey(rawValue: "serialization.model")
    }
    
    /**
     When supporting an additional data-type, this method must be extended.
     */
    public init(from decoder: Decoder) throws {
        
        self.init()
        
        if
            let key = Self.deserializerInfoKey,
            let userInfoDeserializer = decoder.userInfo[key] as? Self {
            
            self = userInfoDeserializer
        }
        
        if
            let key = Self.modelInfoKey,
            let model = decoder.userInfo[key] as? Model {
            
            self.model = model
        }
        
        let container = try decoder.container(keyedBy: DynamicKey.self)
        
        var builder = FieldBuilder<Self>(modelHolder: self)
        builder.decodingContainer = container
        try makeFields(builder: &builder)
    }
}
