//
//  RongCloudIMAPIService.swift
//  rabbitDoctor
//
//  Created by Mac on 2017/8/29.
//  Copyright © 2017年 rabbitDoctor. All rights reserved.
//

import Foundation
import Moya

fileprivate let endpointClosure = { (target: RongCloudIMAPIService) -> Endpoint<RongCloudIMAPIService> in
    let url = target.baseURL.appendingPathComponent(target.path).absoluteString
    
    if Utils.getValueFromUserDefault(key: "userId") != "" {
        headerFields["TBSAccessToken"] = Utils.getValueFromUserDefault(key: "accessToken")
    }
    
    return Endpoint(url: url, sampleResponseClosure: {.networkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters)
        .adding(parameters: appendedParams ?? nil)
        .adding(newHTTPHeaderFields: headerFields)
        .adding(parameterEncoding: target.parameterEncoding)
}

let rongCloudIMAPIProvider = RxMoyaProvider<RongCloudIMAPIService>(endpointClosure: endpointClosure, plugins: [NetworkLoggerPlugin(verbose: true, responseDataFormatter: JSONResponseDataFormatter)])

enum RongCloudIMAPIService {
    case addChat(userId: String, toUserID: String, content: String, houseId: Int, houseName: String)
}

extension RongCloudIMAPIService: TargetType {
    var baseURL: URL { return URL.init(string: Url_domain)!}
    
    var path: String {
        switch self {
        case .addChat(_):
            return "rabbit/v1/im/addChat"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .addChat(_):
            return .post
        default:
            return .get
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .addChat(let userId, let toUserID, let content, let houseId, let houseName):
            return [
                "userId": userId,
                "toUserID": toUserID,
                "content": content,
                "houseId": houseId,
                "houseName": houseName
            ]
        default:
            return nil
        }
    }
    
    var sampleData: Data {
        return "".data(using: .utf8)!
    }
    
    var parameterEncoding: Moya.ParameterEncoding {
        switch self {
        default:
            return URLEncoding.default
        }
    }
    
    var task: Task {
        return .request
    }
    
}

