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
            Pet(id: 1, type: .doggy, name: "Kathleen", age: 11, whiskers: true, adoptedAt: Date()),
            Pet(id: 2, type: .kitty, name: "Miso", age: 43, whiskers: true, adoptedAt: nil)
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
    
    var shouldDecodeAge = true
    
    func makeFields(builder b: inout FieldBuilder<Pet>) {
        b.add("id", \.id)
        b.add(
            "type",
            model.type.rawValue,
            { self.model.type = PetType(rawValue: $0)! }
        )
        b.add("name", \.name)
        b.add("age", \.age, shouldEncode: self.model.age > 10, shouldDecode: self.shouldDecodeAge)
        b.add("whiskers", \.whiskers)
        b.add("adoptedAt", \.adoptedAt)
    }
    
    static var type = "pet"
    var model = Pet()
    var storeId = \Pet.storeId
}



//
// Models
//
struct Fruit {
    var storeId: String { return "\(id!)" }
    var id: Int?
    var name = ""
}

struct Loop {
    var storeId: String { return "\(id!)" }
    var id: Int?
    var name = ""
}

//
// Serializable Extensions
//
extension Fruit : Serializable {
    func makeSerializer() -> FruitSerializer {
        return FruitSerializer(model: self)
    }
}

extension Loop : Serializable {
    func makeSerializer() -> LoopSerializer {
        return LoopSerializer(model: self)
    }
}


//
// Serializers
//
final class FruitSerializer : Serializer {
    
    func sideLoadResources(builder b: inout SideLoadedResourceBuilder) {
        b.add(Loop(id: 2, name: "Loopy"))
    }
    
    func makeFields(builder b: inout FieldBuilder<Fruit>) {
        b.add("name", \.name)
    }
    
    static var type = "fruit"
    var model = Fruit()
    var storeId = \Fruit.storeId
}

final class LoopSerializer : Serializer {
    
    func sideLoadResources(builder b: inout SideLoadedResourceBuilder) {
        b.add(Fruit(id: 2, name: "Apple")) // This is necessary to test infinite loop doesn't happen
    }
    
    func makeFields(builder b: inout FieldBuilder<Loop>) {
        b.add("name", \.name)
    }
    
    static var type = "loop"
    var model = Loop()
    var storeId = \Loop.storeId
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
            XCTAssertEqual(obj["pet"]?["1"]?["age"] as? Int, 11)
            XCTAssertNil(obj["pet"]?["1"]?["adoptedAt"] as? NSNull)
            XCTAssertEqual(obj["pet"]?["1"]?["id"] as? Int, 1)
            XCTAssertEqual(obj["pet"]?["2"]?["name"] as? String, "Miso")
            XCTAssertEqual(obj["pet"]?["2"]?["type"] as? String, "kitty")
            XCTAssertEqual(obj["pet"]?["2"]?["whiskers"] as? Bool, true)
            XCTAssertEqual(obj["pet"]?["2"]?["age"] as? Int, 43)
            XCTAssertNotNil(obj["pet"]?["2"]?["adoptedAt"] as? NSNull)
            XCTAssertEqual(obj["pet"]?["2"]?["id"] as? Int, 2)
            
        } else {
            XCTFail("Could not convert serialization to expected shape")
        }
        
        try pretty(json)

    }
    
    func testShouldEncode() throws {
        let pet = Pet.init(id: 88, type: .kitty, name: "Jane", age: 9, whiskers: true, adoptedAt: nil)
        
        let serializer = pet.makeSerializer()
        let output = serializer.makeSerialization()
        
        let jsonEncoder = JSONEncoder()
        let json = try jsonEncoder.encode(output)
        let obj = try json.toJSONObject()
        
        if let obj = obj as? [String: [String: [String: Any]]] {
            XCTAssertEqual(obj.count, 1)
            XCTAssertEqual(obj["pet"]?.count, 1)
            XCTAssertEqual(obj["pet"]?["88"]?["name"] as? String, "Jane")
            XCTAssertEqual(obj["pet"]?["88"]?["type"] as? String, "kitty")
            XCTAssertNil(obj["pet"]?["88"]?["age"]) // Age is not encoded because it is over 10
            
        } else {
            XCTFail("Could not convert serialization to expected shape")
        }
    }
    
    func testShouldDecode() throws {
        let json = """
            {
                "id": 77,
                "name": "June",
                "type": "doggy",
                "age": 2
            }
            """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let deserializer = PetSerializer()
        deserializer.shouldDecodeAge = false
        let key = CodingUserInfoKey(rawValue: "serialization.deserializer")!
        decoder.userInfo = [key: deserializer]
        
        let pet = try decoder.decode(PetSerializer.self, from: json).model
        XCTAssertEqual(pet.id, 77)
        XCTAssertEqual(pet.name, "June")
        XCTAssertEqual(pet.age, 0)
    }
    
    func testInfiniteLoop() throws {
        let fruit = Fruit(id: 2, name: "Apple")
        let serializer = fruit.makeSerializer()
        let output = serializer.makeSerialization()
        
        let jsonEncoder = JSONEncoder()
        let json = try jsonEncoder.encode(output)
        let obj = try json.toJSONObject()
        
        if let obj = obj as? [String: [String: [String: Any]]] {
            XCTAssertEqual(obj.count, 2)
            XCTAssertEqual(obj["fruit"]?.count, 1)
            XCTAssertEqual(obj["loop"]?.count, 1)
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
        ("testShouldEncode", testShouldEncode),
        ("testShouldDecode", testShouldDecode),
        ("testInfiniteLoop", testInfiniteLoop),
    ]
}
