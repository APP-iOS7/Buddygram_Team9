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
    let id: String        // Firestore 문서 ID - 게시물의 고유 식별자
    let ownerUid: String  // 작성자의 UID - 사용자 인증 ID로 누가 작성했는지 식별
    let ownerUsername: String // 작성자의 사용자 이름 - UI에 표시
    let ownerProfileImageURL: String? // 작성자의 프로필 이미지 URL - 게시물 헤더에 표시
    var caption: String?  // 게시물 설명/내용 - 사용자가 작성한 텍스트
    let imageURL: String  // 게시물 이미지 URL - 업로드된 이미지 표시용
    var likeCount: Int    // 좋아요 수 - 게시물 인기도 표시
    var commentCount: Int // 댓글 수 - 게시물 활동성 표시
    var createdAt: Date   // 생성 날짜 - 게시물 타임라인 정렬용
    var likedBy: [String] // 좋아요한 사용자 ID 목록 - 좋아요 상태 확인 및 취소용
    var location: String? // 위치 정보 (선택 사항) - 게시물 위치 표시
    var tags: [String]?   // 태그 목록 (선택 사항) - 게시물 검색 및 분류용
}
