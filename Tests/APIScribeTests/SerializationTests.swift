import XCTest
import DeepTraverse
@testable import APIScribe

//
// Models
//
struct Kid {
    var storeId: String { return "\(id!)" }
    var id: Int?
    var name = ""
    var age: Int = 0
    var hobbies: [String] = []
    var nickName = "" // WritableKeyPath
    
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
class PetContext : Context {
    var withWhiskers = true
    var contextForEmbeddedKid = true
}

extension Kid : Serializable {
    func makeSerializer(in context: Context? = nil) -> KidSerializer {
        return KidSerializer(model: self, in: context)
    }
}

extension Pet : Serializable {
    func makeSerializer(in context: Context? = nil) -> PetSerializer {
        let s = PetSerializer(model: self, in: context)
        
        if let petContext = context as? PetContext {
            s.includeWhiskers = petContext.withWhiskers
        }
        
        return s
    }
}


//
// Serializers
//
final class KidSerializer : Serializer {

    func sideLoadResources(builder b: inout SideLoadedResourceBuilder) {
        b.add(model.pets())
    }
    
    func makeFields(builder b: inout FieldBuilder<KidSerializer>) throws {
        try b.field("name", \.name)
        try b.readOnly("age", \.age)
        try b.readOnly("hobbies", \.hobbies, shouldEncode: self.shouldEncodeHobbies)
        try b.writeOnly("nickName", \.nickName, shouldDecode: false)
    }
    
    var shouldEncodeHobbies: Bool {
        if let context = self.context as? PetContext {
            return context.contextForEmbeddedKid
        }
        return false
    }
    
    static var storeKey = "kid"
    var model = Kid()
    var context: Context?
}

final class PetSerializer : Serializer {
    
    var shouldDecodeAge = true
    var includeWhiskers = true
    var writableField = [""]
    var kid: Kid?
    var anotherKid: Kid?
    
    func makeFields(builder b: inout FieldBuilder<PetSerializer>) throws {
        try b.field("id", \.id)
        try b.field(
            "type",
            model.type.rawValue,
            { self.model.type = PetType(rawValue: $0)! }
        )
        try b.field("name", model.name, { self.model.name = $0 })
        try b.writeOnly("writableField", { self.writableField = $0 })
        try b.readOnly("abilities", ["landsOnAllFours": model.landsOnAllFours])
        try b.field("name", \.name)
        try b.field("age", \.age, shouldEncode: self.model.age > 10, shouldDecode: self.shouldDecodeAge)
        try b.field("whiskers", \.whiskers, shouldEncode: self.includeWhiskers, shouldDecode: true)
        try b.field("adoptedAt", \.adoptedAt)
        try b.embeddedResource("kid", self.kid, { self.kid = $0 })
        try b.writeOnlyEmbeddedResource("anotherKid", { self.anotherKid = $0 }, using: KidSerializer.self)
    }
    
    static var storeKey = "pet"
    var model = Pet()
    var context: Context?
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
    func makeSerializer(in context: Context? = nil) -> FruitSerializer {
        return FruitSerializer(model: self, in: context)
    }
}

extension Loop : Serializable {
    func makeSerializer(in context: Context? = nil) -> LoopSerializer {
        return LoopSerializer(model: self, in: context)
    }
}


//
// Serializers
//
final class FruitSerializer : Serializer {
    
    func sideLoadResources(builder b: inout SideLoadedResourceBuilder) {
        b.add(Loop(id: 2, name: "Loopy"))
    }
    
    func makeFields(builder b: inout FieldBuilder<FruitSerializer>) throws {
        try b.field("name", \.name)
    }
    
    static var storeKey = "fruit"
    var model = Fruit()
    var context: Context?
}

final class LoopSerializer : Serializer {
    
    func sideLoadResources(builder b: inout SideLoadedResourceBuilder) {
        b.add(Fruit(id: 2, name: "Apple")) // This is necessary to test infinite loop doesn't happen
    }
    
    func makeFields(builder b: inout FieldBuilder<LoopSerializer>) throws {
        try b.field("name", \.name)
    }
    
    static var storeKey = "loop"
    var model = Loop()
    var context: Context?
}

final class SerializationTests: XCTestCase {
    
    func testDeserializeFromPartialInput() throws {
        // No need to pass entire serialized model. In this case `whiskers` is missing.
        let json = """
            {
                "id": 99,
                "name": "Rover",
                "type": "doggy",
                "age": 2,
                "writableField": ["this", "worked"]
            }
            """.data(using: .utf8)!
        
        let petSerializer = try JSONDecoder().decode(PetSerializer.self, from: json)
        let pet = petSerializer.model
        XCTAssertEqual(pet.id, 99)
        XCTAssertEqual(pet.name, "Rover")
        XCTAssertEqual(pet.type, .doggy)
        XCTAssertEqual(pet.age, 2)
        XCTAssertEqual(petSerializer.writableField, ["this", "worked"])
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
            
        let kid = Kid(id: 1, name: "Sara", age: 10, hobbies: ["baseball"], nickName: "")
        let serializer = kid.makeSerializer()

        let jsonEncoder = JSONEncoder()
        let json = try jsonEncoder.encode(serializer)
        let obj = try json.toJSONObject()
        
        if let obj = obj as? [String: [String: [String: Any]]] {
            XCTAssertEqual(obj.count, 2)
            XCTAssertEqual(obj["kid"]?.count, 1)
            XCTAssertEqual(obj["kid"]?["1"]?["name"] as? String, "Sara")
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
            
            let j = try JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
            print(String.init(data: j, encoding: .utf8)!)
            
            
        } else {
            XCTFail("Could not convert serialization to expected shape")
        }
    }
    
    func testShouldEncode() throws {
        let pet = Pet(id: 88, type: .kitty, name: "Jane", age: 9, whiskers: true, adoptedAt: nil)
        
        let serializer = pet.makeSerializer()
        
        let jsonEncoder = JSONEncoder()
        let json = try jsonEncoder.encode(serializer)
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
        
        let jsonEncoder = JSONEncoder()
        let json = try jsonEncoder.encode(serializer)
        let obj = try json.toJSONObject()
        
        if let obj = obj as? [String: [String: [String: Any]]] {
            XCTAssertEqual(obj.count, 2)
            XCTAssertEqual(obj["fruit"]?.count, 1)
            XCTAssertEqual(obj["loop"]?.count, 1)
        } else {
            XCTFail("Could not convert serialization to expected shape")
        }
    }
    
    func testSerializeArray() throws {
        
        let pets = [
            Pet(id: 88, type: .kitty, name: "Jane", age: 9, whiskers: true, adoptedAt: nil),
            Pet(id: 99, type: .doggy, name: "Jin", age: 2, whiskers: true, adoptedAt: Date()),
        ]
        
        let jsonEncoder = JSONEncoder()
        let json = try jsonEncoder.encode(pets.makeSerializer())
        let obj = try json.toJSONObject()
        
        if let obj = obj as? [String: [String: [String: Any]]] {
            XCTAssertEqual(obj.count, 1)
            XCTAssertEqual(obj["pet"]?.count, 2)
            XCTAssertEqual(obj["pet"]?["88"]?["name"] as? String, "Jane")
            XCTAssertEqual(obj["pet"]?["99"]?["name"] as? String, "Jin")
            
        } else {
            XCTFail("Could not convert serialization to expected shape")
        }
        
        try pretty(json)
    }
    
    func testSerializationWithContext() throws {
        
        let pet = Pet(id: 3, type: .kitty, name: "Tuna", age: 1, whiskers: true, adoptedAt: nil)
        let context = PetContext()
        context.withWhiskers = false
        let serializer = pet.makeSerializer(in: context)
        
        let jsonEncoder = JSONEncoder()
        let json = try jsonEncoder.encode(serializer)
        let obj = try json.toJSONObject()
        
        if let obj = obj as? [String: [String: [String: Any]]] {
            XCTAssertEqual(obj.count, 1)
            XCTAssertEqual(obj["pet"]?.count, 1)
            XCTAssertNil(obj["pet"]?["3"]?["whiskers"])
            
        } else {
            XCTFail("Could not convert serialization to expected shape")
        }
    }
    
    func testEmbeddedResource() throws {
        
        let json = """
            {
                "id": 4,
                "adoptedAt": null,
                "kid": {
                    "id": 8,
                    "name": "Georgie",
                    "age": 9
                }
            }
            """.data(using: .utf8)!
        
        let jsonDecoder = JSONDecoder()
        let serializer = try jsonDecoder.decode(PetSerializer.self, from: json)
        
        // Read only fields not deserialized
        // Deserialization of embedded resource worked
        XCTAssertEqual(serializer.kid?.name, "Georgie")
        // Read only fields not deserialized, therefore KidSerializer was used
        XCTAssertEqual(serializer.kid?.age, 0)
    }
    
    func testWriteOnlyEmbeddedResource() throws {
        
        let json = """
            {
                "id": 4,
                "adoptedAt": null,
                "anotherKid": {
                    "id": 8,
                    "name": "Georgie",
                    "age": 9
                }
            }
            """.data(using: .utf8)!
        
        let jsonDecoder = JSONDecoder()
        let serializer = try jsonDecoder.decode(PetSerializer.self, from: json)
        
        XCTAssertEqual(serializer.anotherKid?.name, "Georgie")
        
        let jsonEncoder = JSONEncoder()
        let obj = try jsonEncoder.encode(serializer).toJSONObject() as? [String: Any]
        XCTAssertNotNil(obj)
        XCTAssertEqual(obj?.deepGet("pet", "4", "anotherKid", "id") as? Int, nil)
    }
    
    func testContextIsPassedToEmbeddedResources() throws {
        let pet = Pet(id: 4, type: .doggy, name: "Judge Dredd", age: 7, whiskers: true, adoptedAt: Date())
        let petSerializer = pet.makeSerializer(in: nil)
        petSerializer.kid = Kid(id: 88, name: "Kimmy", age: 13, hobbies: ["podcasting"], nickName: "")
        
        let jsonEncoder = JSONEncoder()
        var json = try jsonEncoder.encode(petSerializer)
        
        try pretty(json)
        
        var obj = try json.toJSONObject() as? [String: Any]
        XCTAssertNotNil(obj)
        XCTAssertEqual(obj?.deepGet("pet", "4", "kid", "name") as? String, "Kimmy")
        XCTAssertEqual(obj?.deepGet("pet", "4", "kid", "hobbies") as? [String], nil)
        
        let context = PetContext()
        context.contextForEmbeddedKid = true
        petSerializer.context = context

        json = try jsonEncoder.encode(petSerializer)
        obj = try json.toJSONObject() as? [String: Any]
        XCTAssertEqual(obj?.deepGet("pet", "4", "kid", "hobbies") as? [String], ["podcasting"])
    }
    
    func testReadOnlyWritableKeyPath() throws {
        let json = """
            {
                "id": 4,
                "name": "Taro",
                "nickName": "Jumpin' Jack"
            }
            """.data(using: .utf8)!
        
        let jsonDecoder = JSONDecoder()
        let serializer = try jsonDecoder.decode(KidSerializer.self, from: json)
        
        XCTAssertEqual(serializer.model.name, "Taro")
        XCTAssertEqual(serializer.model.nickName, "")
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
        ("testSerializeArray", testSerializeArray),
        ("testSerializationWithContext", testSerializationWithContext),
        ("testEmbeddedResource", testEmbeddedResource),
        ("testWriteOnlyEmbeddedResource", testWriteOnlyEmbeddedResource),
        ("testContextIsPassedToEmbeddedResources", testContextIsPassedToEmbeddedResources),
        ("testReadOnlyWritableKeyPath", testReadOnlyWritableKeyPath),
    ]
}
