//
//  FirebaseManager.swift
//  Huilo
//
//  Created by Eduard Kanevskii on 14.12.2022.
//

import Foundation
import Firebase

final class FirebaseManager {
//    let auth: Auth
    let storage: StorageReference
    let firestore: Firestore
    
    static let shared = FirebaseManager()
    
    init() {
//        FirebaseApp.configure()
//        auth = Auth.auth()
        storage = Storage.storage().reference()
        firestore = Firestore.firestore()
    }
}

struct ReferenceKeys {
    static let users = "users"
    static let nickName = "nickName"
    static let profileImageURL = "profileImageURL"
    static let userID = "userID"
    static let email = "email"
}
