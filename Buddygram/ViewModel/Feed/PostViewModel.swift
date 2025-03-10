//
//  PostViewModel.swift
//  Buddygram
//
//  Created by 3/10/25.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage
import UIKit

class PostViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage().reference()
    
    // HomeView: 게시물 가져오기
    func fetchAllPosts(completion: @escaping () -> Void = {}) {
        isLoading = true
        errorMessage = ""
        
        db.collection("posts")
            .order(by: "createdAt", descending: true)
            .getDocuments { [weak self] (snapshot, error) in
                guard let self = self else { return }
                
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "게시물을 불러오는 중 오류가 발생했습니다.: \(error.localizedDescription)"
                    completion()
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.errorMessage = "게시물이 없습니다."
                    completion()
                    return
                }
                
                self.posts = documents.compactMap { document -> Post? in
                    let data = document.data()
                    
                    guard let ownerUid = data["ownerUid"] as? String,
                          let ownerUsername = data["ownerUsername"] as? String,
                          let imageURL = data["imageURL"] as? String,
                          let timestamp = data["createdAt"] as? Timestamp else {
                        return nil
                    }
                    
                    return Post(
                        id: document.documentID,
                        ownerUid: ownerUid,
                        ownerUsername: ownerUsername,
                        ownerProfileImageURL: data["ownerProfileImageURL"] as? String,
                        caption: data["caption"] as? String,
                        imageURL: imageURL,
                        likeCount: data["likeCount"] as? Int ?? 0,
                        commentCount: data["commentCount"] as? Int ?? 0,
                        createdAt: timestamp.dateValue(),
                        likedBy: data["likedBy"] as? [String] ?? [],
                        location: data["location"] as? String,
                        tags: data["tags"] as? [String]
                    )
                }
                
                completion()
            }
    }
    
    // ProfileView: 게시물 가져오기
    func fetchUserPosts(uid: String, completion: @escaping ([Post]) -> Void = {_ in}) {
        isLoading = true
        errorMessage = ""
        
        db.collection("posts")
            .whereField("ownerUid", isEqualTo: uid)
            .order(by: "createdAt", descending: true)
            .getDocuments { [weak self] (snapshot, error) in
                guard let self = self else { return }
                
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "게시물을 불러오는 중 오류가 발생했습니다.: \(error.localizedDescription)"
                    completion([])
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.errorMessage = "해당 사용자의 게시물이 없습니다."
                    completion([])
                    return
                }
                
                let userPosts = documents.compactMap { document -> Post? in
                    let data = document.data()
                    
                    guard let ownerUid = data["ownerUid"] as? String,
                          let ownerUsername = data["ownerUsername"] as? String,
                          let imageURL = data["imageURL"] as? String,
                          let timestamp = data["createdAt"] as? Timestamp else {
                        return nil
                    }
                    
                    return Post(
                        id: document.documentID,
                        ownerUid: ownerUid,
                        ownerUsername: ownerUsername,
                        ownerProfileImageURL: data["ownerProfileImageURL"] as? String,
                        caption: data["caption"] as? String,
                        imageURL: imageURL,
                        likeCount: data["likeCount"] as? Int ?? 0,
                        commentCount: data["commentCount"] as? Int ?? 0,
                        createdAt: timestamp.dateValue(),
                        likedBy: data["likedBy"] as? [String] ?? [],
                        location: data["location"] as? String,
                        tags: data["tags"] as? [String]
                    )
                }
                completion(userPosts)
            }
        
    }
    
    // 게시물 업로드
    func uploadPost(image: UIImage, caption: String, user: User, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = ""
        
        // 이미지 데이터 변환
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            isLoading = false
            errorMessage = "이미지 변환 중 오류가 발생했습니다."
            completion(false)
            return
        }
        
        // 고유 파일 이름 생성
        let filename = UUID().uuidString
        let ref = storage.child("post_images/\(filename).jpg")
        
        // 이미지 업로드
        ref.putData(imageData, metadata: nil) { [weak self] (_, error) in
            guard let self = self else { return }
            
            if let error = error {
                isLoading = false
                self.errorMessage = "이미지를 업로드중 오류가 발생했습니다.: \(error.localizedDescription)"
                completion(false)
                return
            }
            
            // 업로드된 이미지 가져오기
            ref.downloadURL() { [weak self] (url, error) in
                guard let self = self else { return }
                
                if let error = error {
                    self.isLoading = false
                    self.errorMessage = "이미지 URL을 가져오는 중 오류가 발생했습니다. :\(error.localizedDescription)"
                    completion(false)
                    return
                }
                
                guard let imageURL = url?.absoluteString else {
                    self.isLoading = false
                    self.errorMessage = "이미지 경로가 유효하지 않습니다."
                    completion(false)
                    return
                }
                
                // Firestore에 게시물 정보 저장
                let postData: [String: Any] = [
                    "ownerUid": user.id,
                    "ownerUsername": user.username,
                    "ownerProfileImageURL": user.profileImageURL as Any,
                    "caption": caption,
                    "imageURL": imageURL,
                    "likeCount": 0,
                    "commentCount": 0,
                    "createdAt": Timestamp(date: Date()),
                    "likedBy": []
                ]
                
                self.db.collection("posts").addDocument(data: postData) { [weak self] error in
                    guard let self = self else { return }
                    
                    self.isLoading = false
                    
                    if let error = error {
                        self.errorMessage = "게시물 저장 중 오류가 발생했습니다.: \(error.localizedDescription)"
                        completion(false)
                        return
                    }
                    
                    // 성공적으로 업로드된 후 게시물 목록 새로고침
                    self.fetchAllPosts {
                        completion(true)
                    }
                }
            }
        }
    }
    
    // 좋아요 버튼
    func toggleLike(postId: String, userId: String, completion: @escaping (Bool) -> Void = {_ in}) {
        let postRef = db.collection("posts").document(postId)
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let postDocument: DocumentSnapshot
            
            do {
                try postDocument = transaction.getDocument(postRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard let post = postDocument.data() else {
                return nil
            }
            
            var likedBy = post["likedBy"] as? [String] ?? []
            var likeCount = post["likeCount"] as? Int ?? 0
            
            if likedBy.contains(userId) {
                // 좋아요 취소
                likedBy.removeAll { $0 == userId }
                likeCount = max(0, likeCount - 1)
            } else {
                // 좋아요 추가
                likedBy.append(userId)
                likeCount += 1
            }
            
            transaction.updateData([
                "likedBy": likedBy,
                "likeCount": likeCount
            ], forDocument: postRef)
            
            return [
                "success": true,
                "liked": likedBy.contains(userId)
            ]
        }) { [weak self] (result, error) in
            if let error = error {
                print("좋아요 처리 중 오류 발생: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            // 게시물 목록 새로고침
            self?.fetchAllPosts {
                completion(true)
            }
        }
    }
}
