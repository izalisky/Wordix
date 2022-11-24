//
//  AuthRequest.swift
//  CRMRealtyRuler
//
//  Created by Ігор on 3/1/19.
//  Copyright © 2019 Igor Zalisky. All rights reserved.
//

import Foundation
import Alamofire


class ApiRequests: ServerRequest<AnyObject> {

    func request(_ type:RequestType,  closure: @escaping (AnyObject?, Error?)->()) {
        let urlStr = "\(self.baseUrlString)/\(type.rawValue)"
        
        self.request(url: urlStr, params: [:] as [String : AnyObject], headers: nil, method: .get) { (response) in
            closure(response.responseObject as AnyObject?,nil)
        }
    }
    
    func language(_ closure: @escaping (AnyObject?, Error?)->()) {
        let urlStr = "\(self.baseUrlString)/language"
        
        self.request(url: urlStr, params: [:] as [String : AnyObject], headers: nil, method: .get) { (response) in
            closure(response.responseObject as AnyObject?,nil)
        }
    }
    
    func bonusgame (_ closure: @escaping (AnyObject?, Error?)->()) {
        let url_str = "\(self.baseUrlString)/bonus-game"
        self.request(url: url_str, params: [:] as [String : AnyObject], headers: nil, method: .get) { (response) in
            closure(response.responseObject as AnyObject?,nil)
        }
    }
    
    func level (_ closure: @escaping (AnyObject?, Error?)->()) {
        let url_str = "\(self.baseUrlString)/level"
        self.request(url: url_str, params: [:] as [String : AnyObject], headers: nil, method: .get) { (response) in
            
            closure(response.responseObject, nil)
        }
    }
    
    func word (_ closure: @escaping (AnyObject?, Error?)->()) {
        let url_str = "\(self.baseUrlString)/word"
        self.request(url: url_str, params: [:] as [String : AnyObject], headers: nil, method: .get) { (response) in
            closure(response.responseObject as AnyObject?,nil)
        }
    }
    
    
}
