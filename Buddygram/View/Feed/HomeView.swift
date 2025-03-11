//
//  HomeView.swift
//  Buddygram
//
//  Created by KimJunsoo on 3/6/25.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseStorage
import Kingfisher

struct HomeView: View {
    // 바인딩 제거, 환경객체 사용
    @Binding var selectedTab: Int
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var postViewModel: PostViewModel
    @State private var isRefreshing = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                // 새로고침 컨트롤
                RefreshControl(isRefreshing: $isRefreshing) {
                    postViewModel.fetchAllPosts {
                        isRefreshing = false
                    }
                }
                
                // Firebase에서 가져온 Post 모델을 사용하여 게시물 표시
                LazyVStack(spacing: 20) {
                    ForEach(postViewModel.posts) { post in
                        FirebasePostView(post: post)
                            .environmentObject(postViewModel)
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                await withCheckedContinuation { continuation in
                    postViewModel.fetchAllPosts {
                        continuation.resume()
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Buddygram")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(LinearGradient(
                            gradient: Gradient(colors: [Color.green, Color.green, Color.green, Color.pink, Color.pink, Color.purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                }
            }
            .background(Color(.systemGray6)) 
        }
        .onAppear {
            if !postViewModel.isLoading {
                postViewModel.fetchAllPosts()
            }
        }
    }
}

// FirebasePostView: Firebase에서 가져온 Post 모델을 사용하는 뷰
struct FirebasePostView: View {
    let post: Post
    @State private var isShowingComments = false
    @State private var newComment = ""
    @State private var isLiked: Bool
    @State private var animateLike = false
    
    @EnvironmentObject var postViewModel: PostViewModel
    
    init(post: Post) {
        self.post = post
        let currentUserId = Auth.auth().currentUser?.uid ?? ""
        self._isLiked = State(initialValue: post.likedBy.contains(currentUserId))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 사용자 정보
            HStack {
                if let profileURL = post.ownerProfileImageURL, let url = URL(string: profileURL) {
                    KFImage(url)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.gray)
                }
                
                Text(post.ownerUsername)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text(post.createdAt, style: .date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)
            
            // 게시물 이미지
            if let url = URL(string: post.imageURL) {
                KFImage(url)
                    .placeholder {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .overlay(
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            )
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 300)
                    .clipped()
                    .cornerRadius(10)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 300)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    )
                    .cornerRadius(10)
            }
            
            // 캡션
            if let caption = post.caption {
                Text(caption)
                    .padding(.horizontal)
                    .padding(.top, 4)
            }
            
            // 좋아요, 댓글, 채팅 버튼
            HStack(spacing: 20) {
                // 좋아요 버튼
                Button(action: {
                    if !postViewModel.isLoading {
                        toggleLike() // 버그 해결 중 1. 좋아요 버튼
                        
                    }
                    withAnimation(.easeInOut(duration: 0.3)) {
                        animateLike = isLiked
                    }
                }) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .resizable()
                        .frame(width: 24, height: 22)
                        .foregroundColor(.red)
                        .scaleEffect(animateLike ? 1.2 : 1.0)
                }
                
                Text("\(post.likeCount)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                // 댓글 버튼
                Button(action: {
                    isShowingComments.toggle()
                }) {
                    Image(systemName: "message")
                        .resizable()
                        .frame(width: 22, height: 22)
                        .foregroundColor(.black)
                }
                
                Text("\(post.commentCount)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                // 채팅 버튼
                NavigationLink(destination: ChatView(username: post.ownerUsername)) {
                    Image(systemName: "paperplane.fill")
                        .resizable()
                        .frame(width: 22, height: 22)
                        .foregroundColor(.green)
                }
                
                Spacer()
                    .padding()
            }
            .padding(.horizontal)
            
            // 댓글창 (isShowingComments가 true일 때만 표시)
            if isShowingComments {
                VStack(alignment: .leading, spacing: 5) {
                    if post.commentCount == 0 {
                        Text("아직 댓글이 없습니다.")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.vertical, 2)
                    }
                    
                    // 댓글 입력창
                    HStack {
                        TextField("댓글 입력...", text: $newComment)
                            .padding(10)
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(radius: 1)
                        
                        Spacer()
                        
                        Button(action: {
                            if !newComment.isEmpty {
                                // 댓글 추가 로직 (Firebase에 저장)
                                
                                // UI 즉시 업데이트
                                newComment = ""
                            }
                        }) {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.green)
                                .clipShape(Circle())
                                .frame(width: 25, height: 25)
                        }
                        .padding(.leading, 5)
                    }
                    .padding(.horizontal)
                }
                .padding(.horizontal)
            }
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 3)
        .padding(.vertical, 8)
    }
    
    // Firebase 좋아요 토글 기능
    private func toggleLike() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        print("좋아요 토글 시작 - 게시물 ID: \(post.id), 사용자 ID: \(userId)")
        isLiked.toggle()
        
        postViewModel.toggleLike(postId: post.id, userId: userId) { success in
            if !success {
                // 실패시 상태 복원
                isLiked.toggle()
            }
        }
    }
}


