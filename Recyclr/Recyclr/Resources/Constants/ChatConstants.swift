//
//  ChatConstants.swift
//  Recyclr
//
//  Created by Christopher Alegre on 11/7/19.
//  Copyright © 2019 Christopher Alegre. All rights reserved.
//

import Firebase

struct Constants {
    struct refs {
        static let databaseRoot = Database.database().reference()
        static let databaseChat = databaseRoot.child("chats")
    }
}
