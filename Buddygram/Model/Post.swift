//
//  Post.swift
//  Buddygram
//
//  Created by KimJunsoo on 3/6/25.
//

import Foundation
import SwiftUI
import Combine
import Firebase

struct Post: Identifiable, Codable {
    let id: String  // Firestore 문서 ID
    let ownerUid: String  // 작성자의 UID
    let ownerUsername: String
    let ownerProfileImageURL: String?
    var caption: String?
    let imageURL: String
    var likeCount: Int
    var commentCount: Int
    var createdAt: Date
    var likedBy: [String]  // 좋아요한 사용자 ID 목록
    var location: String?
    var tags: [String]?
}
