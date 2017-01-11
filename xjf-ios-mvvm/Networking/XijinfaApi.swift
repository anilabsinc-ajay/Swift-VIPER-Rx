//
//  XijinfaApi.swift
//  xjf-ios-mvvm
//
//  Created by xijinfa on 1/5/17.
//  Copyright © 2017 xijinfa. All rights reserved.
//

import Foundation
import Moya

private func JSONResponseDataFormatter(_ data: Data) -> Data {
    do {
        let dataAsJSON = try JSONSerialization.jsonObject(with: data)
        let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
        return prettyData
    } catch {
        return data
    }
}

enum XijinfaApi {
    case banner(path:String)
    case secureCode
    case login(userName:String, passwd:String, secureCode:String, secureKey:String)
}

extension XijinfaApi: TargetType {

    var baseURL: URL {
        return URL(string: "https://api.rc.xijinfa.com/api/")!
    }

    var path: String {
        switch self {
        case .banner(let path):
            return "banner/\(path)"
        case .secureCode:
            return "auth/get-secure-code"
        case .login:
            return "auth/login"
        }
    }

    var method: Moya.Method {
        switch self {
        case .login:
            return .post
        default:
            return .get
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .login(let userName, let passwd, let secureCode, let secureKey):
           return [
                "username": userName,
                "password": passwd,
                "secure_key": secureKey,
                "secure_code": secureCode]
        default:
            return nil
        }
    }

    public var parameterEncoding: ParameterEncoding {
        return method == .get ? URLEncoding.default : JSONEncoding.default
    }

    public var task: Task {
        return .request
    }

    var headers: [String: String]? {
        switch self {
        case .login:
            return ["X-XJF-UDID": udid,
                    "X-XJF-PLATFORM": "ios",
                    "X-XJF-VERSION": bundleVersion,
                    "X-XJF-CLIENT": client,
                    "X-XJF-PUSH-CHANNEL": "xiaomi"]
        default:
            guard let token = token else {
                return ["Accept": "application/json", "Cache-Control": "no-cache"]
            }
            return ["Authorization": "bearer \(token)", "Accept": "application/json", "Cache-Control": "no-cache"]
        }
    }

    var token: String? {
        return nil
    }

    public var validate: Bool {
        switch self {
        case .banner:
            return true
        default:
            return false
        }
    }

    public var sampleData: Data {
        switch self {
        case .banner(_):
            return stubbedResponse("Banner")
        default:
            return Data()
        }
    }

    func stubbedResponse(_ filename: String) -> Data! {
        @objc class TestClass: NSObject { }
        let bundle = Bundle(for: TestClass.self)
        let path = bundle.path(forResource: filename, ofType: "json")
        return (try? Data(contentsOf: URL(fileURLWithPath: path!)))
    }

    var udid: String {
        return (UIDevice.current.identifierForVendor?.uuidString)!
    }

    var client: String {
        return UIDevice.current.name
    }

    var bundleVersion: String {
        if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            return version
        }
        return ""
    }
}
