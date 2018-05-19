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
            Creation(registrationCode: "regcode", passed: 3, failed: 1),
            Creation(registrationCode: "otherregcode", passed: 2, failed: 2)
        ]
    }
}

struct Creation {
    var registrationCode: String = ""
    var passed: Int = 0
    var failed: Int = 0
    
    func total() -> Int {
        return passed + failed
    }
}

//
// Serializable Extensions
//
extension CertificateBundle : Serializable {
    func makeSerializer() -> CertificateBundleSerializer {
        return CertificateBundleSerializer(model: self)
    }
}

extension Creation : Serializable {
    func makeSerializer() -> CreationSerializer {
        return CreationSerializer(model: self)
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
    
    func makeFields(builder: inout FieldBuilder<CertificateBundle>) {
        builder.add("reference", \.reference)
        
        if includeQuantity {
            builder.add("quantity", \.quantity)
        }
    }
    
    static var type = "certificateBundle"
    var model = CertificateBundle()
    var storeId = \CertificateBundle.reference
}

final class CreationSerializer : Serializer, Deserializer {
 
    func makeFields(builder: inout FieldBuilder<Creation>) {
        builder.add("registrationCode", \.registrationCode)
        builder.add("passed", \.passed)
        builder.add("failed", \.failed)
    }
    
    static var type = "creation"
    var model = Creation()
    var storeId = \Creation.registrationCode
}

final class SerializationTests: XCTestCase {
    
    func testDeserialization() throws {
        let json = """
            {
                "registrationCode": "newregcode",
                "passed": 7
            }
            """.data(using: .utf8)!
        
        let creation = try JSONDecoder().decode(CreationSerializer.self, from: json).model
        XCTAssertEqual(creation.registrationCode, "newregcode")
        XCTAssertEqual(creation.passed, 7)
    }
    
    func testSerialization() {
        
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


//    static var allTests = [
//        // TODO
//    ]
}
