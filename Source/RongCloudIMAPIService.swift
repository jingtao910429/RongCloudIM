////
////  RongCloudIMAPIService.swift
////  rabbitDoctor
////
////  Created by Mac on 2017/8/29.
////  Copyright © 2017年 rabbitDoctor. All rights reserved.
////
//
//import Foundation
//import Moya
//
//var headerFields: Dictionary<String, String> = [
//    "Content-Type": "application/json",
//    "deviceType": "1",
//    "apiVersion": "1"
//]
//
//var appendedParams: Dictionary<String, Any>?
//
//func JSONResponseDataFormatter(_ data: Data) -> Data {
//    do {
//        let dataAsJSON = try JSONSerialization.jsonObject(with: data)
//        let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
//        return prettyData
//    } catch {
//        return data //fallback to original data if it cant be serialized
//    }
//}
//
//fileprivate let endpointClosure = { (target: RongCloudIMAPIService) -> Endpoint<RongCloudIMAPIService> in
//    let url = target.baseURL.appendingPathComponent(target.path).absoluteString
//    
//    //    if Utils.getValueFromUserDefault(key: "userId") != "" {
//    //        headerFields["TBSAccessToken"] = Utils.getValueFromUserDefault(key: "accessToken")
//    //    }
//    //
//    return Endpoint(url: url, sampleResponseClosure: {.networkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters)
//        .adding(parameters: appendedParams ?? nil)
//        .adding(newHTTPHeaderFields: headerFields)
//        .adding(parameterEncoding: target.parameterEncoding)
//}
//
//let rongCloudIMAPIProvider = RxMoyaProvider<RongCloudIMAPIService>(endpointClosure: endpointClosure, plugins: [NetworkLoggerPlugin(verbose: true, responseDataFormatter: JSONResponseDataFormatter)])
//
//enum RongCloudIMAPIService {
//    case customerAddChat(userId: String, toUserID: String, content: String, houseId: Int, houseName: String)
//    case agentAddChat(userId: String, toUserID: String, content: String, houseId: Int, houseName: String)
//    case getCustomerUserInfo(userId: String)
//    case getAgentUserInfo(userId: String)
//}
//
//extension RongCloudIMAPIService: TargetType {
//    var baseURL: URL { return URL.init(string: "")!}
//    
//    var path: String {
//        switch self {
//        case .customerAddChat(_):
//            return "rabbit/v1/im/addChat"
//        case .agentAddChat(_):
//            return "im/addChat"
//        case .getCustomerUserInfo(_):
//            return "rabbit/v1/im/getTargetInfo"
//        case .getAgentUserInfo(_):
//            return "im/getTargetInfo"
//        }
//    }
//    
//    var method: Moya.Method {
//        switch self {
//        case .customerAddChat(_):
//            return .post
//        case .agentAddChat(_):
//            return .post
//        default:
//            return .get
//        }
//    }
//    
//    var parameters: [String: Any]? {
//        switch self {
//        case .customerAddChat(let userId, let toUserID, let content, let houseId, let houseName):
//            return [
//                "userId": userId,
//                "toUserID": toUserID,
//                "content": content,
//                "houseId": houseId,
//                "houseName": houseName
//            ]
//        case .agentAddChat(let userId, let toUserID, let content, let houseId, let houseName):
//            return [
//                "userId": userId,
//                "toUserID": toUserID,
//                "content": content,
//                "houseId": houseId,
//                "houseName": houseName
//            ]
//        case .getAgentUserInfo(let userId):
//            return [
//                "userId": userId
//            ]
//        case .getCustomerUserInfo(let userId):
//            return [
//                "userId": userId
//            ]
//        default:
//            return nil
//        }
//    }
//    
//    var sampleData: Data {
//        return "".data(using: .utf8)!
//    }
//    
//    var parameterEncoding: Moya.ParameterEncoding {
//        switch self {
//        default:
//            return URLEncoding.default
//        }
//    }
//    
//    var task: Task {
//        return .request
//    }
//    
//}
//
