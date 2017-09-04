//
//  MessageType.swift
//  rabbit
//
//  Created by PixelShi on 2017/1/16.
//  Copyright © 2017年 lychinahouse. All rights reserved.
//

import UIKit

class MessageType: RCMessageContent {
    var house_name: String = ""
    var house_id: Int = 0
    var city_id: Int = 0
    var sprice: Int = 0
    var sale_count: Int = 0
    var isfirst: String = ""
    var extra: String = ""

    override func encode() -> Data {
        let dataDict: NSMutableDictionary = NSMutableDictionary()

        dataDict.setValue(house_name, forKey: "house_name")
        dataDict.setValue(house_id, forKey: "house_id")
        dataDict.setValue(city_id, forKey: "city_id")
        dataDict.setValue(sprice, forKey: "sprice")
        dataDict.setValue(sale_count, forKey: "sale_count")
        dataDict.setValue(isfirst, forKey: "isfirst")
        dataDict.setValue(extra, forKey: "extra")
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

            if let id = dic["house_name"] as? String {
                house_name = id
            }
            if let id = dic["house_id"] as? Int {
                house_id = id
            }
            if let id = dic["city_id"] as? Int {
                city_id = id
            }
            if let id = dic["sprice"] as? Int {
                sprice = id
            }
            if let id = dic["sale_count"] as? Int {
                sale_count = id
            }
            if let id = dic["isfirst"] as? String {
                isfirst = id
            }
            if let id = dic["extra"] as? String {
                extra = id
            }
        } catch {

        }
    }

    override func conversationDigest() -> String! {
        return self.house_name
    }

    override class func getObjectName() -> String! {
        return "2boss:house"
    }

}
