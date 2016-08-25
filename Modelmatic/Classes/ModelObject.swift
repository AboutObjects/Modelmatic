//
// Copyright (C) 2015 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this example's licensing information.
//

import Foundation
import CoreData

// TODO: Make this configurable.
public let KVCPropertyPrefix = "kvc_"

public class ModelObject : NSObject
{
    var entity: NSEntityDescription!
    
    public required init(dictionary: JsonDictionary, entity: NSEntityDescription)
    {
        self.entity = entity
        super.init()
        decodeAttributeValues(dictionary)
        decodeRelationshipValues(dictionary)
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
        var dict = attributeValues
        for (key, value) in relationshipValues {
            dict[key] = value
        }
        return dict
    }
    
    // TODO: Add exception handling. Consider adding custom KVC methods that throw.
    // Probably need to construct intervening dictionaries, as needed.
    //
    public var attributeValues: JsonDictionary {
        get { return encodedAttributeValues }
        set { decodeAttributeValues(newValue) }
    }
    
    public var relationshipValues: JsonDictionary {
        get { return encodedRelationshipValues }
        set { decodeRelationshipValues(newValue) }
    }
    
    var encodedAttributeValues: JsonDictionary {
        let encodededVals: NSMutableDictionary = NSMutableDictionary()
        for (_, attribute) in entity.attributesByName {
            let val = encodedValue(forAttribute: attribute)
            if val !== NSNull() {
                encodededVals.setValue(val, forKeyPath: attribute.externalKeyPath)
            }
        }
        return encodededVals.copy() as! JsonDictionary
    }
    
    var encodedRelationshipValues: JsonDictionary {
        let encodedVals: NSMutableDictionary = NSMutableDictionary()
        for (_, relationship) in entity.relationshipsByName {
            let val = encodedValue(forRelationship: relationship)
            if val !== NSNull() {
                encodedVals.setValue(val, forKeyPath: relationship.externalKeyPath)
            }
        }
        return encodedVals.copy() as! JsonDictionary
    }
    
    func encodedValue(forAttribute attribute: NSAttributeDescription) -> AnyObject
    {
        var value = valueForKey(attribute.name)
        if value != nil,
            let transformerName = attribute.valueTransformerName,
            let transformer = NSValueTransformer(forName: transformerName) {
            value = transformer.transformedValue(value)
        }
        return value ?? NSNull()
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
        else if let obj = value as? ModelObject where relationship.inverseRelationship == nil {
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
            let val = (dictionary as NSDictionary).valueForKeyPath(attribute.externalKeyPath)
            decode(val, forAttribute: attribute)
        }
    }
    
    public func decodeRelationshipValues(dictionary: JsonDictionary)
    {
        for (_, relationship) in entity.relationshipsByName {
            if let val = (dictionary as NSDictionary).valueForKeyPath(relationship.externalKeyPath) {
                if let dicts = val as? [JsonDictionary] where relationship.toMany {
                    setBothSidesOfRelationship(relationship, withValuesFromDictionaries: dicts)
                }
                else if let dict = val as? JsonDictionary {
                    setBothSidesOfRelationship(relationship, withValuesFromDictionary: dict)
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
    
    public func setBothSidesOfRelationship(relationship: NSRelationshipDescription, withValuesFromDictionaries dictionaries: [JsonDictionary])
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
    
    public func setBothSidesOfRelationship(relationship: NSRelationshipDescription, withValuesFromDictionary dictionary: JsonDictionary)
    {
        guard let dict = (dictionary as NSDictionary).valueForKeyPath(relationship.externalKeyPath) as? JsonDictionary else {
            return
        }
        
        let modelObj = modelObject(withDictionary: dict, relationship: relationship)
        if let key = relationship.inverseRelationship?.name {
            modelObj.setValue(self, forKey: key)
        }
        setValue(modelObj, forKey: relationship.name)
    }
}