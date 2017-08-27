//
//  RecipePappyAPI.swift
//  RecipeFinder
//
//  Created by sergey on 8/15/17.
//  Copyright © 2017 sergey. All rights reserved.
//

import Foundation
import Moya

// MARK: - Provider setup

private func JSONResponseDataFormatter(_ data: Data) -> Data {
    do {
        let dataAsJSON = try JSONSerialization.jsonObject(with: data)
        let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
        return prettyData
    } catch {
        return data // fallback to original data if it can't be serialized.
    }
}

let RecipePappy = MoyaProvider<Recipe>(plugins: [NetworkLoggerPlugin(verbose: true, responseDataFormatter: JSONResponseDataFormatter)])

// MARK: - Provider support

private extension String {
    var urlEscaped: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
}

public enum Recipe {
    case recipe(String)
}

extension Recipe: TargetType {
    public var baseURL: URL { return URL(string: "http://www.recipepuppy.com/api/")! }
    public var path: String {
        switch self {
        default:
            return ""
        }
    }
    public var method: Moya.Method {
        return .get
    }
    
    
    public var parameters: [String: Any]? {
        switch self {
        case .recipe(let recipeName):
            return ["q": "\(recipeName.urlEscaped)"]
        }
    }
 
    public var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
    public var task: Task {
        return .request
    }
    public var validate: Bool {
        switch self {
        default:
            return false
        }
    }
    public var sampleData: Data {
        switch self {
        case .recipe( _):
            return "{\"results\": \"[]\"}".data(using: String.Encoding.utf8)!
        }
    }
    public var headers: [String: String]? {
        return nil
    }
}

public func url(_ route: TargetType) -> String {
    return route.baseURL.appendingPathComponent(route.path).absoluteString
}

//MARK: - Response Handlers

extension Moya.Response {
    func mapNSDictionary() throws -> NSDictionary {
        let any = try self.mapJSON()
        guard let dict = any as? NSDictionary else {
            throw MoyaError.jsonMapping(self)
        }
        return dict
    }
}
