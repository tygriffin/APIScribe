//
//  FieldMaker.swift
//  APIScribe
//
//  Created by Taylor Griffin on 10/8/18.
//

public protocol FieldMaker: ContextHolder, ModelHolder {
    
    /// Fields that contain coding instructions
    func makeFields(builder: inout FieldBuilder<Self>) throws
}
