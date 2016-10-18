//
//  Pricing.swift
//  Modelmatic
//
//  Created by Jonathan Lehr on 8/26/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation

import Modelmatic

@objc(MDLPricing)
class Pricing: ModelObject
{
    static let entityName = "Pricing"
    
    var pricingId: NSNumber!
    var retailPrice: Double?
    var discountedPrice: Double?
    
    // IMPORTANT: Use weak reference when modeling inverse relationship.
    weak var book: Book?
    
    override  var description: String {
        return "\(super.description) retail: \(retailPrice); discounted price: \(discountedPrice))"
    }
}

extension Pricing
{
    var kvc_retailPrice: Double {
        get { return retailPrice ?? 0.0 }
        set { retailPrice = Optional(newValue) }
    }

    var kvc_discountedPrice: Double {
        get { return discountedPrice ?? 0.0 }
        set { discountedPrice = Optional(newValue) }
    }
}
