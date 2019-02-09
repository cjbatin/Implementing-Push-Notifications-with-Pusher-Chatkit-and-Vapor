//
//  Constants.swift
//  ChatKing
//
//  Created by Christopher Batin on 09/02/2019.
//  Copyright © 2019 Christopher Batin. All rights reserved.
//

import Foundation
import PusherChatkit

let baseURL = "https://93e24f61.ngrok.io/"
//let baseURL = "http://localhost:8080/"
struct Constants {
    static let createUserURL = URL.init(string: "\(baseURL)/api/users/new")!
    static let loginURL = URL.init(string: "\(baseURL)/api/users/login")!
    static let chatkitInstance = "v1:us1:1a87e1e8-eca4-4109-8b5d-1dce3bdd6eaa"
}
