//
//  VJLiveActivityAttributes.swift
//  LiveActivityDemo
//
//  Created by Ethan on 2022/10/26.
//


import ActivityKit
import Foundation

enum VJLiveActivityAttributesState: String, Codable {
   case processing
   case prepping
   case delivering
   case completed
}

enum VJLiveActivityOrderTypeState: String, Codable {
    case procfootballMatchessing
    case pizzaDelivery
}

struct VJLiveActivityAttributes: ActivityAttributes {
   typealias VJAttributesState = ContentState

   public struct ContentState: Codable, Hashable {
       public var timestamp:    String
       public var message:      String?
       public var driverName:   String
       public var courier:      String
       public var numberOfPizzas:String
       public var Score:        String
       public var originScore:  String
       public var totalAmount:  String
       public var avatar:       String
       public var deliveryState: VJLiveActivityAttributesState
   }

   public var orderType: VJLiveActivityOrderTypeState
}


