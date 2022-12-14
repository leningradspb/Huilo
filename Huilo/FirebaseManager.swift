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
    let storage: Storage
    let firestore: Firestore
    
    static let shared = FirebaseManager()
    
    init() {
//        FirebaseApp.configure()
//        auth = Auth.auth()
        storage = Storage.storage()
        firestore = Firestore.firestore()
    }
}
