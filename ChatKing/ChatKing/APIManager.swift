//
//  APIManager.swift
//  ChatKing
//
//  Created by Christopher Batin on 09/02/2019.
//  Copyright © 2019 Christopher Batin. All rights reserved.
//

import Foundation
import Alamofire
import NotificationBannerSwift
import PusherChatkit

// 1
struct User: Codable {
    var id: String
    var username: String
}
// 2
struct Room: Codable {
    var name: String
}

// 3
let baseURL = "YOUR_NGROK_HTTPS_URL"
var chatManager: ChatManager?
struct Constants {
    static let createUserURL = URL.init(string: "\(baseURL)/api/users/new")!
    static let loginURL = URL.init(string: "\(baseURL)/api/users/login")!
    //This is the full form with the locator as well
    static let chatkitInstance = "YOUR_CHATKIT_INSTANCE_ID"
}

class APIManager {

    // 4
    func createNewUser(username: String, withCompletion completion: @escaping (User?) -> Void) {
        let parameters: Parameters = [
            "username": username
        ]
        Alamofire.request(Constants.createUserURL, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { (response) in
            let statusCode = response.response?.statusCode ?? -1
            if 200 ... 299 ~= statusCode {
                if let data = response.data {
                    do {
                        let decoder = JSONDecoder.init()
                        let currentUser = try decoder.decode(User.self, from: data)
                        completion(currentUser)
                    } catch {
                        completion(nil)
                    }
                }
            } else {
                let banner = StatusBarNotificationBanner(title: "Something went wrong, this user may already exist!", style: .danger)
                banner.show()
                completion(nil)
            }
        }
    }

    // 5
    func login(username: String, withCompletion completion: @escaping (User?) -> Void) {
        let parameters: Parameters = [
            "username": username
        ]
        Alamofire.request(Constants.loginURL, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { (response) in
            let statusCode = response.response?.statusCode ?? -1
            if 200 ... 299 ~= statusCode {
                if let data = response.data {
                    do {
                        let decoder = JSONDecoder.init()
                        let currentUser = try decoder.decode(User.self, from: data)
                        completion(currentUser)
                    } catch {
                        completion(nil)
                    }
                }
            }else {
                let banner = StatusBarNotificationBanner(title: "Something went wrong, this user may not exist yet!", style: .danger)
                banner.show()
                completion(nil)
            }
        }
    }

    // 6
    func createRoom(userId: String, room: Room, withCompletion completion: @escaping (Room?) -> Void) {
        let parameters = [
            "name": room.name,
            ]
        let url = URL.init(string: "\(baseURL)/api/rooms/new/user/\(userId)")!
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { (response) in
            let statusCode = response.response?.statusCode ?? -1
            if 200 ... 299 ~= statusCode {
                if let data = response.data {
                    do {
                        let decoder = JSONDecoder.init()
                        let newRoom = try decoder.decode(Room.self, from: data)
                        completion(newRoom)
                    } catch {
                        completion(nil)
                    }
                }
            } else {
                let banner = StatusBarNotificationBanner(title: "Something went wrong, this room may already exist", style: .danger)
                banner.show()
                completion(nil)
            }
        }
    }
}
