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
        
        
    }
}
