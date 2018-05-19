import XCTest
@testable import Serialization

//
// Primary Models
//
struct CertificateBundle {
    var reference: String = ""
    var quantity: Int = 0
    
    func creations() -> [Creation] {
        return [
            Creation(registrationCode: "regcode", passed: 3),
            Creation(registrationCode: "otherregcode", passed: 2)
        ]
    }
}

struct Creation {
    var registrationCode: String = ""
    var passed : Int = 0
}

//
// Serializable Extensions
//
extension CertificateBundle : Serializable {
    func makeSerializer() -> CertificateBundleSerializer {
        let s = CertificateBundleSerializer()
        s.model = self
        return s
    }
}

extension Creation : Serializable {

    func makeSerializer() -> CreationSerializer {
        let s = CreationSerializer()
        s.model = self
        return s
    }
}

//
// Serializers
//
final class CertificateBundleSerializer : Serializer {
    
    var includeQuantity = true
    
    func sideLoadResources(builder: inout SideLoadedResourceBuilder) {
        builder.add(model.creations())
    }
    
    func makeFields(builder: inout FieldBuilder) {
        builder.add("reference", model.reference)
        
        if includeQuantity {
            builder.add("quantity", model.quantity)
        }
    }
    
    static var type: StorableType = .certificateBundle
    var model = CertificateBundle()
    var storeId: String { return model.reference }
}

final class CreationSerializer : Serializer {
 
    func makeFields(builder: inout FieldBuilder) {
        builder.add("registrationCode", model.registrationCode)
        builder.add("passed", model.passed)
    }
    
    static var type: StorableType = .creation
    var model = Creation()
    var storeId: String { return model.registrationCode }
}

final class SerializationTests: XCTestCase {
    
    func testExample() {
        
        do {
            
            let cb = CertificateBundle(reference: "ref", quantity: 34)
            
            let serializer = cb.makeSerializer()
            serializer.includeQuantity = false
            
            let s = serializer.makeSerialization()
            

            let jsonEncoder = JSONEncoder()
            let json = try jsonEncoder.encode(s)
            try pretty(json)

            
        } catch {
            print(error)
        }
    }
    
    func pretty(_ data: Data) throws {
        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        let pretty = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        print(String(data: pretty, encoding: .utf8)!)
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
