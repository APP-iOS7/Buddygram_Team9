//
//  Post.swift
//  Buddygram
//
//  Created by KimJunsoo on 3/6/25.
//

import Foundation
import FirebaseFirestoreSwift

struct Post: Identifiable, Codable {
    @DocumentID var id: String?
    let userId: String
    let username: String
    let userProfileImageUrl: String?
    let caption: String
    let imageUrl: String
    var likes: Int
    var commentCount: Int
    let timestamp: Date
    var didLike: Bool? = false
    
    // Firestore의 custom fields를 위한 CodingKeys
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case username
        case userProfileImageUrl = "user_profile_image_url"
        case caption
        case imageUrl = "image_url"
        case likes
        case commentCount = "comment_count"
        case timestamp
        case didLike = "did_like"
    }
}
