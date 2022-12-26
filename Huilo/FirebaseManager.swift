//
//  FirebaseManager.swift
//  Huilo
//
//  Created by Eduard Kanevskii on 14.12.2022.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage

final class FirebaseManager {
//    let auth: Auth
    let storage: StorageReference
    let firestore: Firestore
    let auth: Auth
    
    static let shared = FirebaseManager()
    
    init() {
//        FirebaseApp.configure()
        auth = Auth.auth()
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
    static let usersHistory = "usersHistory"
    static let photos = "photos"
    static let results = "results"
}
