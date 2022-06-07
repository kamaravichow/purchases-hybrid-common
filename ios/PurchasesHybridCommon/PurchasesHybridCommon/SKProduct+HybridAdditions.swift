//
//  SKProduct+HybridAdditions.swift
//  PurchasesHybridCommon
//
//  Created by Andrés Boedo on 4/13/22.
//  Copyright © 2022 RevenueCat. All rights reserved.
//

import Foundation
import RevenueCat
import StoreKit

@objc public extension StoreProduct {

    @objc var rc_dictionary: [String: Any] {
        var dictionary: [String: Any] = [
            "currency_code": self.currencyCode ?? NSNull(),
            "description": self.localizedDescription,
            "discounts": NSNull(),
            "identifier": self.productIdentifier,
            "intro_price": NSNull(),
            "intro_price_cycles": NSNull(),
            "intro_price_period": NSNull(),
            "intro_price_period_number_of_units": NSNull(),
            "intro_price_period_unit": NSNull(),
            "intro_price_string": NSNull(),
            "introPrice": NSNull(),
            "price": self.price,
            "price_string": self.localizedPriceString,
            "product_category": self.productCategoryString,
            "product_type": self.productTypeString,
            "title": self.localizedTitle,
        ]

        if #available(iOS 11.2, tvOS 11.2, macOS 10.13.2, *),
           let introductoryDiscount = self.introductoryDiscount {
            dictionary["intro_price"] = introductoryDiscount.price
            dictionary["intro_price_string"] = introductoryDiscount.localizedPriceString
            dictionary["intro_price_period"] = StoreProduct.rc_normalized(subscriptionPeriod: introductoryDiscount.subscriptionPeriod)
            dictionary["intro_price_period_unit"] = StoreProduct.rc_normalized(subscriptionPeriodUnit: introductoryDiscount.subscriptionPeriod.unit)
            dictionary["intro_price_period_number_of_units"] = introductoryDiscount.subscriptionPeriod.value
            dictionary["intro_price_cycles"] = introductoryDiscount.numberOfPeriods
            dictionary["introPrice"] = introductoryDiscount.rc_dictionary
        }

        if #available(iOS 12.2, tvOS 12.2, macOS 10.14.4, *) {
            dictionary["discounts"] = self.discounts.map { $0.rc_dictionary }
        }

        return dictionary
    }

    @objc(rc_normalizedSubscriptionPeriod:)
    static func rc_normalized(subscriptionPeriod: SubscriptionPeriod) -> String {
        let unitString: String
        switch subscriptionPeriod.unit {
        case .day:
            unitString = "D"
        case .week:
            unitString = "W"
        case .month:
            unitString = "M"
        case .year:
            unitString = "Y"
        @unknown default:
            unitString = "-"
        }
        return "P\(subscriptionPeriod.value)\(unitString)"
    }

    @objc(rc_normalizedSubscriptionPeriodUnit:)
    static func rc_normalized(subscriptionPeriodUnit: SubscriptionPeriod.Unit) -> String {
        switch subscriptionPeriodUnit {
        case .day:
            return "DAY"
        case .week:
            return "WEEK"
        case .month:
            return "MONTH"
        case .year:
            return "YEAR"
        @unknown default:
            return "-"
        }
    }

}

private extension StoreProduct {

    var productCategoryString: String {
        switch self.productCategory {
        case .nonSubscription:
            return "NON_SUBSCRIPTION"
        case .subscription:
            return "SUBSCRIPTION"
        }
    }

    var productTypeString: String {
        switch self.productType {
        case .consumable:
            return "CONSUMABLE"
        case .nonConsumable:
            return "NON_CONSUMABLE"
        case .nonRenewableSubscription:
            return "NON_RENEWABLE_SUBSCRIPTION"
        case .autoRenewableSubscription:
            return "AUTO_RENEWABLE_SUBSCRIPTION"
        }
    }

}
