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

// Firebase에 저장되는 사용자 정보를 담는 모델
// 사용자의 기본 정보 및 좋아요한 게시물 ID 목록을 관리
struct User: Identifiable, Codable {
    var id: String // Firebase 인증 ID (고유 식별자)
    var username: String // 사용자 이름
    var email: String // 이메일 주소
    var profileImageURL: String? // 프로필 이미지 URL (옵션)
    var createdAt: Date // 계정 생성 날짜
    var likedPostIDs: [String] = [] // 사용자가 좋아요한 게시물 ID 목록
    var postCount: Int // 사용자가 작성한 게시물 개수
    
    // 추가 : Firebase
    // Firestore 문서를 기반으로 User 모델을 생성하는 함수
    static func fromFirebasestore(document: DocumentSnapshot) -> User? {
        guard let data = document.data() else { return nil }
        
        return User(
            id: document.documentID,
            username: data["username"] as? String ?? "",
            email: data["email"] as? String ?? "",
            profileImageURL: data["profileImageURL"] as? String,
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
            likedPostIDs: data["likePostIDs"] as? [String] ?? [],
            postCount: data["postCount"] as? Int ?? 0 // 추가
        )
    }
}
