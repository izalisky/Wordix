//
//  AuthViewModelType.swift
//  Wordix
//
//  Created by Ihor Zaliskyj on 02.03.2021.
//  Copyright © 2021 Igor Zalisky. All rights reserved.
//

import Foundation
import RealmSwift
import Firebase

protocol AuthViewModelType {
    func loadUserInfo()
    var userInfoDidLoad: (() -> Void)?{get set}
}
