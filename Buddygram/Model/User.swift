//
//  User.swift
//  Buddygram
//
//  Created by KimJunsoo on 3/6/25.
//

import Foundation
import FirebaseFirestoreSwift

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    let username: String
    let email: String
    let profileImageUrl: String?
    var bio: String?
    var fullname: String?
    var followers: Int
    var following: Int
    var postCount: Int
    var isCurrentUser: Bool { return Auth.auth().currentUser?.uid == id }
    
    // Firestore의 custom fields를 위한 CodingKeys
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case email
        case profileImageUrl = "profile_image_url"
        case bio
        case fullname
        case followers
        case following
        case postCount = "post_count"
    }
}
