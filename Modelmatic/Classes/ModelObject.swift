//
// Copyright (C) 2015 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this example's licensing information.
//

import Foundation
import CoreData

public enum MappingError: ErrorType {
    case unknownRelationship(String)
}

// TODO: Make this configurable.
public let KVCPropertyPrefix = "kvc_"

public class ModelObject : NSObject
{
    public let entity: NSEntityDescription
    
    public required init(dictionary: JsonDictionary, entity: NSEntityDescription) {
        self.entity = entity
        super.init()
        decodeRelationshipValues(dictionary)
        decodeAttributeValues(dictionary)
    }
}


// MARK: - Setting/Adding Child Model Objects Programmatically

extension ModelObject
{
    public func relationship(forKey key: String) -> NSRelationshipDescription? {
        return entity.relationshipsByName[key]
    }
    
    public func add(modelObject modelObject: ModelObject, forKey key: String) throws {
        try self.add(modelObjects: [modelObject], forKey: key)
    }
    
    public func add(modelObjects modelObjects: [ModelObject], forKey key: String) throws {
        guard let relationship = relationship(forKey: key) else { throw MappingError.unknownRelationship(key) }
        if let inverseKey = relationship.inverseRelationship?.name {
            for modelObj in modelObjects {
                modelObj.setValue(self, forKey: inverseKey)
            }
        }
        if valueForKey(key) == nil {
            setValue(modelObjects, forKey: key)
            return
        }
        mutableArrayValueForKey(key).addObjectsFromArray(modelObjects)
    }
    
    public func set(modelObject modelObject: ModelObject, forKey key: String) throws {
        guard let relationship = relationship(forKey: key) else { throw MappingError.unknownRelationship(key) }
        if let inverseKey = relationship.inverseRelationship?.name {
            modelObject.setValue(self, forKey: inverseKey)
        }
        setValue(modelObject, forKey: relationship.name)
    }
}


// MARK: - KVC Customization

extension ModelObject
{
    override public func setNilValueForKey(key: String) {
        if !key.hasPrefix(KVCPropertyPrefix) {
            super.setNilValueForKey(key)
        }
        // Silently ignore prefixed keys, so if we're initializing a new instance,
        // the property value will remain .None.
    }
    
    override public func valueForUndefinedKey(key: String) -> AnyObject? {
        return key.hasPrefix(KVCPropertyPrefix) ? nil : super.valueForKey(KVCPropertyPrefix + key)
    }
    
    override public func setValue(value: AnyObject?, forUndefinedKey key: String) {
        if key.hasPrefix(KVCPropertyPrefix) {
            super.setValue(value, forUndefinedKey: key)
        } else {
            super.setValue(value, forKey: KVCPropertyPrefix + key)
        }
    }
}


// MARK: - Encoding

extension ModelObject
{
    public var dictionaryRepresentation: JsonDictionary {
        return encodedValues(parent: self)
    }
    
    func encodedValues(parent parent: ModelObject?) -> JsonDictionary {
        var dict = NSMutableDictionary()
        for (key, value) in encodedRelationshipValues(parent: parent) { dict[key] = value }
        for (_, attribute) in entity.attributesByName { addEncodedValue(forAttribute: attribute, toDictionary: dict, keyPath: attribute.keyPath) }
        guard let jsonDict = dict.copy() as? JsonDictionary else { fatalError("Unable to convert NSMutableDictionary to JsonDictionary") }
        return jsonDict
    }
    // TODO: Error handling improvements -- primarily better (e.g., clearer) console logging
    
    // MARK: - Attributes
    // Note: Doesn't support nested to-many relationships.
    func addEncodedValue(forAttribute attribute: NSAttributeDescription, toDictionary encodedValues: NSMutableDictionary, keyPath: String) {
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
        
    func encodeValue(forAttribute attribute: NSAttributeDescription, toDictionary encodedValues: NSMutableDictionary, key: String) {
        var value = valueForKey(attribute.name)
        if let val = value,
            let transformerName = attribute.valueTransformerName,
            let transformer = NSValueTransformer(forName: transformerName) {
            value = transformer.transformedValue(val)
        }
        
        if let val = value where val !== NSNull() {
            encodedValues[key] = val
        }
    }
    
    // MARK: - Relationships
    
    func encodedRelationshipValues(parent parent: ModelObject?) -> JsonDictionary
    {
        let encodedVals: NSMutableDictionary = NSMutableDictionary()
        for (_, relationship) in entity.relationshipsByName {
            let val = encodedValue(forRelationship: relationship, parent: parent)
            if val !== NSNull() {
                encodedVals.setValue(val, forKeyPath: relationship.keyPath)
            }
        }
        return encodedVals.copy() as! JsonDictionary
    }
    
    func encodedValue(forRelationship relationship: NSRelationshipDescription, parent: ModelObject?) -> AnyObject
    {
        guard let value = valueForKey(relationship.name) where value !== NSNull() else {
            return NSNull()
        }
        
        var encodedVal: AnyObject = NSNull()
        if let modelObjs = value as? [ModelObject] where relationship.toMany {
            encodedVal = modelObjs.dictionaryRepresentation
        } else if let obj = value as? ModelObject, destinationEntity = relationship.destinationEntity, parentEntity = parent?.entity where destinationEntity.name != parentEntity.name {
            encodedVal = obj.encodedValues(parent: parent)
        }
        
        return encodedVal
    }
    
    var encodedRelationshipValues: JsonDictionary {
        let encodedVals: NSMutableDictionary = NSMutableDictionary()
        for (_, relationship) in entity.relationshipsByName {
            let val = encodedValue(forRelationship: relationship)
            if val !== NSNull() {
                encodedVals.setValue(val, forKeyPath: relationship.keyPath)
            }
        }
        return encodedVals.copy() as! JsonDictionary
    }
    
    func encodedValue(forRelationship relationship: NSRelationshipDescription) -> AnyObject
    {
        guard let value = valueForKey(relationship.name) where value !== NSNull() else {
            return NSNull()
        }
        
        var encodedVal: AnyObject = NSNull()
        if let modelObjs = value as? [ModelObject] where relationship.toMany {
            encodedVal = modelObjs.dictionaryRepresentation
        }
        else if let obj = value as? ModelObject, destinationEntity = entity.superentity
            where entity.superentity == nil || entity.superentity!.name != destinationEntity.name {
            encodedVal = obj.dictionaryRepresentation
        }
        
        return encodedVal
    }
}

// MARK: - Decoding

extension ModelObject
{
    public override func setValue(value: AnyObject?, forKey key: String)
    {
        let val = (value === NSNull() ? nil : value)
        super.setValue(val, forKey: key)
    }
    
    public func decodeAttributeValues(dictionary: JsonDictionary)
    {
        for (_, attribute) in entity.attributesByName {
            let val = (dictionary as NSDictionary).valueForKeyPath(attribute.keyPath)
            decode(val, forAttribute: attribute)
        }
    }
    
    public func decodeRelationshipValues(dictionary: JsonDictionary)
    {
        for (_, relationship) in entity.relationshipsByName {
            if let val = (dictionary as NSDictionary).valueForKeyPath(relationship.keyPath) {
                if let dicts = val as? [JsonDictionary] where relationship.toMany {
                    addObjects(toRelationship: relationship, withValuesFromDictionaries: dicts)
                }
                else if let dict = val as? JsonDictionary where valueForKey(relationship.name) == nil {
                    setObject(forRelationship: relationship, withValuesFromDictionary: dict)
                }
            }
        }
    }
    
    func decode(value: AnyObject?, forAttribute attribute: NSAttributeDescription)
    {
        var newValue = value
        if let value = value where value !== NSNull(),
            let transformerName = attribute.valueTransformerName,
            let transformer = NSValueTransformer(forName: transformerName) where
            transformer.dynamicType.allowsReverseTransformation() {
            newValue = transformer.reverseTransformedValue(value) ?? NSNull()
        }
        setValue(newValue, forKey: attribute.name)
    }
    
    
    public func modelObject(withDictionary dictionary: JsonDictionary, relationship: NSRelationshipDescription) -> ModelObject
    {
        guard let targetEntity = relationship.destinationEntity,
            className = targetEntity.managedObjectClassName,
            targetClass: ModelObject.Type = NSClassFromString(className) as? ModelObject.Type
            else {
                print("Unable to resolve target class for \(relationship.destinationEntity)")
                abort()
        }
        
        return targetClass.init(dictionary: dictionary, entity: targetEntity)
    }
    
    public func addObjects(toRelationship relationship: NSRelationshipDescription, withValuesFromDictionaries dictionaries: [JsonDictionary])
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
    
    public func setObject(forRelationship relationship: NSRelationshipDescription, withValuesFromDictionary dictionary: JsonDictionary)
    {
        var dict = dictionary
        if let nestedDict = (dictionary as NSDictionary).valueForKeyPath(relationship.keyPath) as? JsonDictionary {
            dict = nestedDict
        }
        
        let modelObj = modelObject(withDictionary: dict, relationship: relationship)
        if let key = relationship.inverseRelationship?.name {
            modelObj.setValue(self, forKey: key)
        }
        setValue(modelObj, forKey: relationship.name)
    }
}