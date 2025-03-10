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
                
              /* if postViewModel.isLoading && !isRefreshing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding(.top, 50)
                } else {*/
                    // Firebase에서 가져온 Post 모델을 사용하여 게시물 표시
                    LazyVStack(spacing: 20) {
                        ForEach(postViewModel.posts) { post in
                            FirebasePostView(post: post)
                        }
                    }
                    .padding()
                //}
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
                            gradient: Gradient(colors: [Color.green, Color.yellow, Color.purple, Color.pink]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                }
            }
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
    
    @EnvironmentObject var postViewModel: PostViewModel
    
    init(post: Post) {
        self.post = post
        let currentUserId = Auth.auth().currentUser?.uid ?? ""
        self._isLiked = State(initialValue: post.likedBy.contains(currentUserId))
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            // 사용자 이름
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
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.gray)
                }
                
                Text(post.ownerUsername)
                    .font(.headline)
                
                Spacer()
                
                Text(post.createdAt, style: .date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            
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
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 300)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    )
            }
            
            // 캡션
            if let caption = post.caption {
                Text(caption)
                    .padding(.horizontal)
                    .padding(.top, 4)
            }
            
            // 좋아요, 댓글, 채팅 버튼
            HStack {
                // 좋아요 버튼
                Button(action: {
                    toggleLike()
                }) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .foregroundColor(.red)
                }
                
                Text("\(post.likeCount)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                // 댓글 버튼
                Button(action: {
                    isShowingComments.toggle()
                }) {
                    Image(systemName: "message")
                        .foregroundColor(.green)
                }
                
                Text("\(post.commentCount)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                // 채팅 버튼
                NavigationLink(destination: ChatView(username: post.ownerUsername)) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.green)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            // 댓글창 (isShowingComments가 true일 때만 표시)
            if isShowingComments {
                VStack(alignment: .leading, spacing: 5) {
                    if post.commentCount == 0 {
                        Text("아직 댓글이 없습니다.")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.vertical, 2)
                            .padding(.horizontal)
                    }
                    
                    // 댓글 입력창
                    HStack {
                        TextField("댓글 입력...", text: $newComment)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button(action: {
                            if !newComment.isEmpty {
                                // 댓글 기능은 나중에 구현
                                newComment = ""
                            }
                        }) {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.horizontal)
            }
        }
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
    
    private func toggleLike() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        isLiked.toggle() // UI 즉시 업데이트
        
        postViewModel.toggleLike(postId: post.id, userId: userId) { success in
            if !success {
                // 실패시 상태 복원
                isLiked.toggle()
            }
        }
    }
}

