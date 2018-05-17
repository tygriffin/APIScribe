//
//  Serializable.swift
//  Serialization
//
//  Created by Taylor Griffin on 13/5/18.
//

protocol CanMakeSerializer {
    func makeSerializer() -> Serialization
}

protocol ModelSerializerr: Serializer {
    associatedtype Model
    var model: Model { get set }
    
    init(model: Any)
}

extension ModelSerializerr {
    init(model: Any) {
        self.init()
        if let model = model as? Model {
            self.model = model
        }
    }
}

protocol Serializable : CanMakeSerializer {
    associatedtype ModelSerializer: ModelSerializerr
    associatedtype Model
}

extension Serializable {
    func makeSerializer() -> Serialization {
        return Serialization(topSerializer: ModelSerializer(model: self))
    }
}
