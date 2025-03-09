//
//  User.swift
//  Buddygram
//
//  Created by KimJunsoo on 3/6/25.
//

import Foundation
import SwiftUI
import Combine
import Firebase
import FirebaseFirestore

struct User: Identifiable, Codable {

    var id: String
    var username: String
    var email: String
    var profileImageURL: String?
    var createdAt: Date
    var likedPostIDs: [String] = []
    
    // 추가 : Firebase
    static func fromFirebasestore(document: DocumentSnapshot) -> User? {
        guard let data = document.data() else { return nil }
        
        return User(
            id: document.documentID,
            username: data["username"] as? String ?? "",
            email: data["email"] as? String ?? "",
            profileImageURL: data["profileImageURL"] as? String,
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
            likedPostIDs: data["likePostIDs"] as? [String] ?? []
        )
    }
}
