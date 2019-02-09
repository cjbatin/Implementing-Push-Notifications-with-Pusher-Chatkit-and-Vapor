//
//  Message.swift
//  ChatKing
//
//  Created by Christopher Batin on 09/02/2019.
//  Copyright © 2019 Christopher Batin. All rights reserved.
//

import Foundation
import MessageKit

struct Message: MessageType {
    var messageId: String
    var sender: Sender
    var sentDate: Date
    var kind: MessageKind

    init(kind: MessageKind, sender: Sender, messageId: String, date: Date) {
        self.kind = kind
        self.sender = sender
        self.messageId = messageId
        self.sentDate = date
    }

    init(text: String, sender: Sender, messageId: String, date: Date) {
        self.init(kind: .text(text), sender: sender, messageId: messageId, date: date)
    }
}
