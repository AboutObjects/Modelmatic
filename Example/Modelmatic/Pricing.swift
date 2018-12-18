//
//  Pricing.swift
//  Modelmatic
//
//  Created by Jonathan Lehr on 8/26/16.
//  Copyright © 2016 About Objects. All rights reserved.
//

import Foundation

import Modelmatic

@objc(MDLPricing)
class Pricing: ModelObject
{
    static let entityName = "Pricing"
    
    @objc var pricingId: NSNumber!
    
    // Broken in Swift 4 with `Swift 3 @objc inference` disabled
    var retailPrice: Double?
    var discountedPrice: Double?
    
    // IMPORTANT: Use weak references when modeling inverse relationship.
    @objc weak var book: Book?
    
    override var description: String {
        return "\(super.description) retail: \(String(describing: retailPrice)); discounted price: \(String(describing: discountedPrice)))"
    }
}

extension Pricing
{
    @objc var kvc_retailPrice: Double {
        get { return retailPrice ?? 0.0 }
        set { retailPrice = Optional(newValue) }
    }

    @objc var kvc_discountedPrice: Double {
        get { return discountedPrice ?? 0.0 }
        set { discountedPrice = Optional(newValue) }
    }
}
