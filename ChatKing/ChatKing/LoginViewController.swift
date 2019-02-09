//
//  LoginViewController.swift
//  ChatKing
//
//  Created by Christopher Batin on 09/02/2019.
//  Copyright © 2019 Christopher Batin. All rights reserved.
//
import UIKit
import Alamofire
import PusherChatkit
import NotificationBannerSwift

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!

    var currentUser: CurrentUser?

    @IBAction func loginButtonTapped(_ sender: Any) {
        signInUser()
    }

    @IBAction func createUserButtonTapped(_ sender: Any) {
        createNewUser()
    }

    private func createNewUser() {
        guard let username = usernameField.text else {
            let banner = StatusBarNotificationBanner(title: "You need to provide a user name!", style: .danger)
            banner.show()
            return
        }
        APIManager().createNewUser(username: username) { (currentUser) in
            self.currentUser = currentUser
            if self.currentUser != nil {
                self.performSegue(withIdentifier: "toRooms", sender: self)
            }
        }
    }

    private func signInUser() {
        guard let username = usernameField.text else {
            let banner = StatusBarNotificationBanner(title: "You need to provide a user name!", style: .danger)
            banner.show()
            return
        }
        APIManager().login(username: username) { (currentUser) in
            self.currentUser = currentUser
            if self.currentUser != nil {
                self.performSegue(withIdentifier: "toRooms", sender: self)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toRooms" {
            let vc = segue.destination as? RoomsTableViewController
            vc?.currentUserId = currentUser?.id
        }
    }
}
