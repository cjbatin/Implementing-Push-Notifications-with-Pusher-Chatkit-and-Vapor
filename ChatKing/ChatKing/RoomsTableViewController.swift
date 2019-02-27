//
//  RoomsTableViewController.swift
//  ChatKing
//
//  Created by Christopher Batin on 09/02/2019.
//  Copyright © 2019 Christopher Batin. All rights reserved.
//
import UIKit
import PusherChatkit
class RoomsTableViewController: UITableViewController {
    //1
    var currentUser: PCCurrentUser?
    var currentUserId: String!
    var rooms: [PCRoom]? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    var selectedRoom: PCRoom?
    //2
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl?.addTarget(self, action: #selector(refresh(_:)), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl!)
        let tokenProvider = PCTokenProvider(
            url: "\(baseURL)/auth/\(self.currentUserId ?? "")",
            requestInjector: { req -> PCTokenProviderRequest in
                return req
        })
        chatManager = ChatManager(instanceLocator: Constants.chatkitInstance,
                                  tokenProvider: tokenProvider,
                                  userID: currentUserId)
        reloadRooms()
    }

    // 3
    @objc func refresh(_ sender: AnyObject) {
        reloadRooms()
    }

    // 4
    private func reloadRooms() {
        chatManager?.connect(delegate: self) { [unowned self] currentUser, error in
            guard error == nil else {
                print("Error connecting: \(error!.localizedDescription)")
                return
            }
            print("Connected!")
            guard let currentUser = currentUser else { return }
            self.currentUser = currentUser
            self.currentUser?.enablePushNotifications()
            self.rooms = self.currentUser?.rooms
            self.getJoinableRooms()
        }
    }
    // 5
    private func getJoinableRooms() {
        self.currentUser?.getJoinableRooms(completionHandler: { (userRooms, error) in
            for room in userRooms! {
                self.currentUser?.joinRoom(room, completionHandler: { (room, error) in
                    if error == nil {
                        self.rooms = self.currentUser?.rooms
                    }
                    if userRooms?.last == room {
                        DispatchQueue.main.async {
                            self.refreshControl?.endRefreshing()
                        }
                    }
                })
            }
            if error != nil || userRooms?.isEmpty ?? true {
                DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
                }
            }
        })
    }

    //6
    @IBAction func AddRoomButtonPressed(_ sender: Any) {
        let alertController = UIAlertController(title: "Add new room", message: "", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Enter Room Name"
        })
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { alert -> Void in
            let textField = alertController.textFields![0] as UITextField
            APIManager().createRoom(userId: self.currentUserId,
                                    room: Room(name: textField.text ?? "") ) { (room) in
                let deadlineTime = DispatchTime.now() + .seconds(1)
                DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                    self.reloadRooms()
                }
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { (action : UIAlertAction!) -> Void in })


        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toChatRoom" {
            let vc = segue.destination as? RoomViewController
            vc?.currentRoom = selectedRoom
            vc?.currentUser = currentUser
        }
    }
}

extension RoomsTableViewController: PCChatManagerDelegate {}

extension RoomsTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RoomCell") as? RoomCell,
            let room = rooms?[indexPath.row] else {
                return UITableViewCell.init(frame: CGRect.zero)
        }
        cell.roomNameLabel.text = room.name
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRoom = rooms?[indexPath.row]
        performSegue(withIdentifier: "toChatRoom", sender: self)
    }
}
