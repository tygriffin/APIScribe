# API Scribe

Very opinionated API serialization library for Swift.

Assuming you had a couple models like this:

```swift
struct Kid {
    var storeId: String { return "\(id!)" }
    var id: Int?
    var name = ""
    
    func pets() -> [Pet] {
        return [
            Pet(id: 1, type: .doggy, name: "Kathleen", age: 9),
            Pet(id: 2, type: .kitty, name: "Miso", age: 43)
        ]
    }
}

struct Pet {
    var storeId: String { return "\(id!)" }
    
    var id: Int?
    var name = ""
    var age = 0
}
```

1. Make serializers for your models:
```swift
final class KidSerializer : Serializer {
    
    func sideLoadResources(builder b: inout SideLoadedResourceBuilder) {
        b.add(model.pets())
    }
    
    func makeFields(builder b: inout FieldBuilder<KidSerializer>) throws {
        try b.field("name", \.name)
    }
    
    static var storeKey = "kid"
    var model = Kid()
    var context: Context?
}

final class PetSerializer : Serializer {
    
    func makeFields(builder b: inout FieldBuilder<PetSerializer>) throws {
        try b.field("id", \.id)
        try b.field("name", \.name)
        try b.readOnly("age", \.age, encodeWhen: self.model.age > 10)
    }
    
    static var storeKey = "pet"
    var model = Pet()
    var context: Context?
}
```

2. Make your models _Serializable_:
```swift
extension Kid : Serializable {
    func makeSerializer(in context: Context? = nil) -> KidSerializer {
        return KidSerializer(model: self, in: context)
    }
}

extension Pet : Serializable {
    func makeSerializer(in context: Context? = nil) -> PetSerializer {
        return PetSerializer(model: self, in: context)
    }
}
```

Encoding the KidSerializer with JSONEncoder would produce normalized output like this:
```json
{
    "kid" : {
        "1" : {
            "id" : 1,
            "name" : "Jane"
        }
    },
    "pet" : {
        "1" : {
            "id" : 1,
            "name" : "Kathleen"
        },
        "2" : {
            "id" : 2,
            "name" : "Miso",
            "age" : 43
        }
    }
}
```
