import XCTest
@testable import Serialization

//
// Models
//
struct Owner {
    var storeId: String { return "\(id!)" }
    var id: Int?
    var name = ""
    
    func pets() -> [Pet] {
        return [
            Pet(id: 1, type: .doggy, name: "Kathleen", age: 10, whiskers: true, adoptedAt: Date()),
            Pet(id: 2, type: .kitty, name: "Miso", age: 3, whiskers: true, adoptedAt: nil)
        ]
    }
}

enum PetType : String {
    case unknown
    case doggy
    case kitty
}

struct Pet {
    var storeId: String { return "\(id!)" }
    
    var id: Int?
    var type: PetType = .unknown
    var name = ""
    var age = 0
    var whiskers = false
    var adoptedAt: Date?
    
    var landsOnAllFours: Bool {
        return type == .kitty
    }
}

//
// Serializable Extensions
//
extension Owner : Serializable {
    func makeSerializer() -> OwnerSerializer {
        return OwnerSerializer(model: self)
    }
}

extension Pet : Serializable {
    func makeSerializer() -> PetSerializer {
        return PetSerializer(model: self)
    }
}


//
// Serializers
//
final class OwnerSerializer : Serializer {
    
    var includeWhiskers = true
    
    func sideLoadResources(builder b: inout SideLoadedResourceBuilder) {
        b.add(model.pets())
    }
    
    func makeFields(builder b: inout FieldBuilder<Owner>) {
        b.add("name", \.name)
    }
    
    static var type = "owner"
    var model = Owner()
    var storeId = \Owner.storeId
}

final class PetSerializer : Serializer, Deserializer {
 
    func makeFields(builder b: inout FieldBuilder<Pet>) {
        b.add("id", \.id)
        b.add(
            "type",
            model.type.rawValue,
            { self.model.type = PetType(rawValue: $0)! }
        )
        b.add("name", \.name)
        b.add("age", \.age)
        b.add("whiskers", \.whiskers)
        b.add("adoptedAt", \.adoptedAt)
    }
    
    static var type = "pet"
    var model = Pet()
    var storeId = \Pet.storeId
}

final class SerializationTests: XCTestCase {
    
    func testDeserializeFromPartialInput() throws {
        // No need to pass entire serialized model. In this case `whiskers` is missing.
        let json = """
            {
                "id": 99,
                "name": "Rover",
                "type": "doggy",
                "age": 2
            }
            """.data(using: .utf8)!
        
        let pet = try JSONDecoder().decode(PetSerializer.self, from: json).model
        XCTAssertEqual(pet.id, 99)
        XCTAssertEqual(pet.name, "Rover")
        XCTAssertEqual(pet.type, .doggy)
        XCTAssertEqual(pet.age, 2)
    }
    
    func testDeserializeToExistingModel() throws {
        let json = """
            {
                "id": 4,
                "name": "Marla",
                "age": 4
            }
            """.data(using: .utf8)!
        
        let existingPet = Pet(id: 4, type: .kitty, name: "Marla", age: 3, whiskers: true, adoptedAt: nil)
        
        let decoder = JSONDecoder()
        let key = CodingUserInfoKey(rawValue: "serialization.model")!
        decoder.userInfo = [key: existingPet]
        let pet = try decoder.decode(PetSerializer.self, from: json).model
        XCTAssertEqual(pet.id, 4)
        XCTAssertEqual(pet.name, "Marla")
        XCTAssertEqual(pet.type, .kitty)
        XCTAssertEqual(pet.whiskers, true)
        XCTAssertEqual(pet.age, 4) // Only age was updated
    }
    
    func testNullifyOptionalValue() throws {
        let json = """
            {
                "id": 4,
                "adoptedAt": null
            }
            """.data(using: .utf8)!
        
        let existingPet = Pet(id: 4, type: .kitty, name: "Marla", age: 3, whiskers: true, adoptedAt: Date())
        XCTAssertNotNil(existingPet.adoptedAt)
        
        let decoder = JSONDecoder()
        let key = CodingUserInfoKey(rawValue: "serialization.model")!
        decoder.userInfo = [key: existingPet]
        let pet = try decoder.decode(PetSerializer.self, from: json).model
        XCTAssertEqual(pet.id, 4)
        XCTAssertEqual(pet.name, "Marla")
        XCTAssertEqual(pet.type, .kitty)
        XCTAssertEqual(pet.whiskers, true)
        XCTAssertEqual(pet.age, 3)
        XCTAssertNil(pet.adoptedAt) // Nullified
    }
    
    func testSerialization() throws {
            
        let owner = Owner(id: 1, name: "Sara")
        let serializer = owner.makeSerializer()
        let output = serializer.makeSerialization()

        let jsonEncoder = JSONEncoder()
        let json = try jsonEncoder.encode(output)
        let obj = try json.toJSONObject()
        
        if let obj = obj as? [String: [String: [String: Any]]] {
            XCTAssertEqual(obj.count, 2)
            XCTAssertEqual(obj["owner"]?.count, 1)
            XCTAssertEqual(obj["owner"]?["1"]?["name"] as? String, "Sara")
            XCTAssertEqual(obj["pet"]?.count, 2)
            XCTAssertEqual(obj["pet"]?["1"]?["name"] as? String, "Kathleen")
            XCTAssertEqual(obj["pet"]?["1"]?["type"] as? String, "doggy")
            XCTAssertEqual(obj["pet"]?["1"]?["whiskers"] as? Bool, true)
            XCTAssertEqual(obj["pet"]?["1"]?["age"] as? Int, 10)
            XCTAssertNil(obj["pet"]?["1"]?["adoptedAt"] as? NSNull)
            XCTAssertEqual(obj["pet"]?["1"]?["id"] as? Int, 1)
            XCTAssertEqual(obj["pet"]?["2"]?["name"] as? String, "Miso")
            XCTAssertEqual(obj["pet"]?["2"]?["type"] as? String, "kitty")
            XCTAssertEqual(obj["pet"]?["2"]?["whiskers"] as? Bool, true)
            XCTAssertEqual(obj["pet"]?["2"]?["age"] as? Int, 3)
            XCTAssertNotNil(obj["pet"]?["2"]?["adoptedAt"] as? NSNull)
            XCTAssertEqual(obj["pet"]?["2"]?["id"] as? Int, 2)
            
        } else {
            XCTFail("Could not convert serialization to expected shape")
        }
        
        try pretty(json)

    }
    
    private func pretty(_ data: Data) throws {
        print(try data.prettyJSONString())
    }


    static var allTests = [
        ("testDeserializeFromPartialInput", testDeserializeFromPartialInput),
        ("testDeserializeToExistingModel", testDeserializeToExistingModel),
        ("testNullifyOptionalValue", testNullifyOptionalValue),
        ("testSerialization", testSerialization),
    ]
}
