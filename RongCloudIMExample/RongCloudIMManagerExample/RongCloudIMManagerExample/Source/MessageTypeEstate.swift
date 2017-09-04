//
//  MessageTypeEstate.swift
//  rabbit
//
//  Created by PixelShi on 2017/1/10.
//  Copyright © 2017年 lychinahouse. All rights reserved.
//

import UIKit

class MessageTypeEstate: RCMessageContent {

    var estate_id: Int = 0
    var rooms: Int = 0
    var living_rooms: Int = 0
    var area: Int = 0
    var unit_price: Int = 0
    var total_price: Int = 0
    var city_id: Int = 0
    var house_id: Int = 0
    var house_name: String = ""
    var is_first: String = ""
    var user: [String: Any] = [:]
    var extra: String = ""
    var estateDetailUrl: String = ""
    var pubType: Int = -1
    var houseType: Int = -1

    override func encode() -> Data {
        let dataDict: NSMutableDictionary = NSMutableDictionary()

        dataDict.setValue(estate_id, forKey: "estate_id")
        dataDict.setValue(rooms, forKey: "rooms")
        dataDict.setValue(living_rooms, forKey: "living_rooms")
        dataDict.setValue(area, forKey: "area")
        dataDict.setValue(unit_price, forKey: "unit_price")
        dataDict.setValue(total_price, forKey: "total_price")
        dataDict.setValue(city_id, forKey: "city_id")
        dataDict.setValue(house_id, forKey: "house_id")
        dataDict.setValue(house_name, forKey: "house_name")
        dataDict.setValue(is_first, forKey: "is_first")
        dataDict.setValue(user, forKey: "user")
        dataDict.setValue(extra, forKey: "extra")
        dataDict.setValue(estateDetailUrl, forKey: "estateDetailUrl")
        dataDict.setValue(pubType, forKey: "pubType")
        dataDict.setValue(houseType, forKey: "houseType")

        do {
            let data = try JSONSerialization.data(withJSONObject: dataDict, options: JSONSerialization.WritingOptions.init(rawValue: 1))
            return data
        } catch {

        }
        return Data()
    }

    override func decode(with data: Data) {
        do {
            let dic: [String: Any?] = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.init(rawValue: 1)) as! [String: Any?]

            if let id = dic["estate_id"] as? Int {
                estate_id = id
            }
            if let id = dic["rooms"] as? Int {
                rooms = id
            }
            if let id = dic["living_rooms"] as? Int {
                living_rooms = id
            }
            if let id = dic["area"] as? Int {
                area = id
            }
            if let id = dic["unit_price"] as? Int {
                unit_price = id
            }
            if let id = dic["total_price"] as? Int {
                total_price = id
            }
            if let id = dic["city_id"] as? Int {
                city_id = id
            }
            if let id = dic["house_id"] as? Int {
                house_id = id
            }
            house_name = dic["house_name"] as! String
            if let id = dic["is_first"] as? NSNumber {
                is_first = id.stringValue
            }
            if let id = dic["extra"] as? String {
                extra = id
            }
            if let id = dic["estateDetailUrl"] as? String {
                estateDetailUrl = id 
            }
            if let id = dic["pubType"] as? Int {
                pubType = id
            }
            if let id = dic["houseType"] as? Int {
                houseType = id
            }

            if let id = dic["user"] as? [String: Any] {
                user = id
            }

            /*
             if let id = dic["user"] as? NSNumber {
             user = id.stringValue
             }

             */

        } catch {

        }
    }

    override func conversationDigest() -> String! {
        return self.house_name
    }

    override class func getObjectName() -> String! {
        return "2boss:estate"
    }
}
