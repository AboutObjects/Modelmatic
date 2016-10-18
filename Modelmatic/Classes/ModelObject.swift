//
// Copyright (C) 2015 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this example's licensing information.
//

import Foundation
import CoreData

public enum MappingError: Error {
    case unknownRelationship(String)
}

// TODO: Make configurable
public let KVCPropertyPrefix = "kvc_"

open class ModelObject : NSObject
{
    open let entity: NSEntityDescription
    
    public required init(dictionary: JsonDictionary, entity: NSEntityDescription) {
        self.entity = entity
        super.init()
        decodeRelationshipValues(dictionary)
        decodeAttributeValues(dictionary)
    }
}

// MARK: - Setting/Adding Child Model Objects Programmatically
public extension ModelObject
{
    open func relationship(forKey key: String) -> NSRelationshipDescription? {
        return entity.relationshipsByName[key]
    }
    
    open func add(modelObject: ModelObject, forKey key: String) throws {
        try self.add(modelObjects: [modelObject], forKey: key)
    }
    
    open func add(modelObjects: [ModelObject], forKey key: String) throws {
        guard let relationship = relationship(forKey: key) else { throw MappingError.unknownRelationship(key) }
        if let inverseKey = relationship.inverseRelationship?.name {
            for modelObj in modelObjects {
                modelObj.setValue(self, forKey: inverseKey)
            }
        }
        if value(forKey: key) == nil {
            setValue(modelObjects, forKey: key)
            return
        }
        mutableArrayValue(forKey: key).addObjects(from: modelObjects)
    }
    
    open func set(modelObject: ModelObject, forKey key: String) throws {
        guard let relationship = relationship(forKey: key) else { throw MappingError.unknownRelationship(key) }
        if let inverseKey = relationship.inverseRelationship?.name {
            modelObject.setValue(self, forKey: inverseKey)
        }
        setValue(modelObject, forKey: relationship.name)
    }
}

// MARK: - KVC Customization
public extension ModelObject
{
    override open func setNilValueForKey(_ key: String) {
        if !key.hasPrefix(KVCPropertyPrefix) {
            super.setNilValueForKey(key)
        }
        // Silently ignore prefixed keys, so if we're initializing a new instance,
        // the property value will remain .None.
    }
    
    override open func value(forUndefinedKey key: String) -> Any? {
        return key.hasPrefix(KVCPropertyPrefix) ? nil : super.value(forKey: KVCPropertyPrefix + key)
    }
    
    override open func setValue(_ value: Any?, forUndefinedKey key: String) {
        if key.hasPrefix(KVCPropertyPrefix) {
            super.setValue(value, forUndefinedKey: key)
        } else {
            super.setValue(value, forKey: KVCPropertyPrefix + key)
        }
    }
}

// MARK: - Encoding
public extension ModelObject
{
    open var dictionaryRepresentation: JsonDictionary {
        return encodedValues(parent: self)
    }
    
    open func encodedValues(parent: ModelObject?) -> JsonDictionary {
        let dict = NSMutableDictionary()
        for (key, value) in encodedRelationshipValues(parent: parent) { dict[key] = value }
        for (_, attribute) in entity.attributesByName { addEncodedValue(forAttribute: attribute, toDictionary: dict, keyPath: attribute.keyPath) }
        guard let jsonDict = dict.copy() as? JsonDictionary else { fatalError("Unable to convert NSMutableDictionary to JsonDictionary") }
        return jsonDict
    }
    // TODO: Error handling improvements -- primarily better (e.g., clearer) console logging
    
    // MARK: - Attributes
    open func addEncodedValue(forAttribute attribute: NSAttributeDescription, toDictionary encodedValues: NSMutableDictionary, keyPath: String) {
        var currDict = encodedValues
        let keys = keyPath.keyPathComponents
        for index in 0..<keys.count - 1 {
            let newDict = NSMutableDictionary()
            currDict[keys[index]] = newDict
            currDict = newDict
        }
        
        if let lastKey = keys.last {
            encodeValue(forAttribute: attribute, toDictionary: currDict, key: lastKey)
        }
    }
        
    open func encodeValue(forAttribute attribute: NSAttributeDescription, toDictionary encodedValues: NSMutableDictionary, key: String) {
        var value = self.value(forKey: attribute.name)
        if let val = value,
            let transformerName = attribute.valueTransformerName,
            let transformer = ValueTransformer(forName: NSValueTransformerName(rawValue: transformerName)) {
            value = transformer.transformedValue(val)
        }
        
        // TODO: Make sure we're encoding null values correctly
        if let val = value, !(value is NSNull) {
            encodedValues[key] = val
        }
    }
    
    // MARK: - Relationships
    open func encodedRelationshipValues(parent: ModelObject?) -> JsonDictionary
    {
        let encodedVals: NSMutableDictionary = NSMutableDictionary()
        for (_, relationship) in entity.relationshipsByName {
            let val = encodedValue(forRelationship: relationship, parent: parent)

            // TODO: Make sure we're encoding null values correctly
            if val !== NSNull() {
                encodedVals.setValue(val, forKeyPath: relationship.keyPath)
            }
        }
        return encodedVals.copy() as! JsonDictionary
    }
    
    open func encodedValue(forRelationship relationship: NSRelationshipDescription, parent: ModelObject?) -> AnyObject
    {
        // TODO: Make sure we're encoding null values correctly
        guard let value = value(forKey: relationship.name), !(value is NSNull) else {
            return NSNull()
        }
        
        var encodedVal: AnyObject = NSNull()
        if let modelObjs = value as? [ModelObject], relationship.isToMany {
            encodedVal = modelObjs.dictionaryRepresentation as AnyObject
        } else if let obj = value as? ModelObject, let destinationEntity = relationship.destinationEntity, let parentEntity = parent?.entity, destinationEntity.name != parentEntity.name {
            encodedVal = obj.encodedValues(parent: parent) as AnyObject
        }
        
        return encodedVal
    }
}

// MARK: - Decoding
public extension ModelObject
{
    open override func setValue(_ value: Any?, forKey key: String)
    {
        // TODO: Make sure we're decoding null values correctly
        let val = (value is NSNull ? nil : value)
        super.setValue(val, forKey: key)
    }
    
    open func decodeAttributeValues(_ dictionary: JsonDictionary)
    {
        for (_, attribute) in entity.attributesByName {
            let val = (dictionary as NSDictionary).value(forKeyPath: attribute.keyPath)
            decode(val as AnyObject?, forAttribute: attribute)
        }
    }
    
    open func decodeRelationshipValues(_ dictionary: JsonDictionary)
    {
        for (_, relationship) in entity.relationshipsByName {
            if let val = (dictionary as NSDictionary).value(forKeyPath: relationship.keyPath) {
                if let dicts = val as? [JsonDictionary], relationship.isToMany {
                    addObjects(toRelationship: relationship, withValuesFromDictionaries: dicts)
                }
                else if let dict = val as? JsonDictionary, value(forKey: relationship.name) == nil {
                    setObject(forRelationship: relationship, withValuesFromDictionary: dict)
                }
            }
        }
    }
    
    open func decode(_ value: AnyObject?, forAttribute attribute: NSAttributeDescription)
    {
        var newValue = value
        if let value = value, value !== NSNull(),
            let transformerName = attribute.valueTransformerName,
            let transformer = ValueTransformer(forName: NSValueTransformerName(rawValue: transformerName)),
            type(of: transformer).allowsReverseTransformation() {
            newValue = transformer.reverseTransformedValue(value) as AnyObject?? ?? NSNull()
        }
        setValue(newValue, forKey: attribute.name)
    }
    
    open func modelObject(withDictionary dictionary: JsonDictionary, relationship: NSRelationshipDescription) -> ModelObject
    {
        guard let targetEntity = relationship.destinationEntity,
            let className = targetEntity.managedObjectClassName,
            let targetClass: ModelObject.Type = NSClassFromString(className) as? ModelObject.Type
            else {
                print("Unable to resolve target class for \(relationship.destinationEntity)")
                abort()
        }
        
        return targetClass.init(dictionary: dictionary, entity: targetEntity)
    }
    
    open func addObjects(toRelationship relationship: NSRelationshipDescription, withValuesFromDictionaries dictionaries: [JsonDictionary])
    {
        let modelObjects = dictionaries.map { dict -> ModelObject in
            let modelObj = modelObject(withDictionary: dict, relationship: relationship)
            if let key = relationship.inverseRelationship?.name {
                modelObj.setValue(self, forKey: key)
            }
            return modelObj
        }
        setValue(modelObjects, forKey: relationship.name)
    }
    
    open func setObject(forRelationship relationship: NSRelationshipDescription, withValuesFromDictionary dictionary: JsonDictionary)
    {
        var dict = dictionary
        if let nestedDict = (dictionary as NSDictionary).value(forKeyPath: relationship.keyPath) as? JsonDictionary {
            dict = nestedDict
        }
        
        let modelObj = modelObject(withDictionary: dict, relationship: relationship)
        if let key = relationship.inverseRelationship?.name {
            modelObj.setValue(self, forKey: key)
        }
        setValue(modelObj, forKey: relationship.name)
    }
}
