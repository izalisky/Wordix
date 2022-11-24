////
//  ServerRequest.swift
//  CRMRealtyRuler
//
//  Created by Ігор on 3/1/19.
//  Copyright © 2019 Igor Zalisky. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

enum ResponseStatus :String{
    case ok
    case error
}

enum RequestType: String {
    case Level = "level"
    case Word = "word"
    case Bonus = "bonus-game"
    case Language = "language"
    case Settings = "config"
    case Question = "question"
    case Users = "users"
}


class ServerRequest<T> {
    let baseUrlString = ""//"http://wordixapp.webtm.ru/api"
    var error: NSError?
    var responseObject: T?
    var jsonData: Data?
    var responseMessage: String?
    var count = 0
    var page = 1
    
    let token :String? = nil
    var progressClosure: ((Double)->())?
    
    
    //MARK: - Interface -
    
    func setTokenHeader() -> [String : String]? {
        var headers = [String: String]()
        
        if token != nil {
            headers["X-Service-Token"] = token
        }
        if headers.isEmpty {
            return nil
        } else {
            return headers
        }
    }
    
    func handleServerMessageFromResponse(_ response: [String : AnyObject]) {
        if let errorMessage = response["error"] as? [String:AnyObject] {
            self.responseMessage = errorMessage["text"] as? String
        }
    }
    
    func request(url:String, params:[String:AnyObject]?, headers:HTTPHeaders?, method:HTTPMethod, closure: @escaping (ServerRequest)->()){
        AF.request(url,
                          method: method,
                          parameters: params,
                          encoding: URLEncoding.default,
                          headers: headers)
            .downloadProgress(closure: { (progress) in
                print("\(progress.fractionCompleted)")
            })
            .responseJSON { (response) in
                
                switch response.result {
                case .success(let responseObject):
                    self.jsonData = response.data
                    self.responseObject = responseObject as? T
                    closure(self)
                    
                case .failure(let error):
                    print(error.localizedDescription)
                    self.error = error as NSError?
                    closure(self)
                }
        }
    }
}
    
