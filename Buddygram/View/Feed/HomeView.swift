//
//  HomeView.swift
//  Buddygram
//
//  Created by KimJunsoo on 3/6/25.
//

import SwiftUI
import Firebase
import FirebaseStorage
import Kingfisher

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var postViewModel: PostViewModel
    @State private var isRefreshing = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 15) {
                    ForEach(postViewModel.posts) { post in
                        PostView(post: post)
                    }
                }
                .padding(.horizontal)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Buddygram")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(LinearGradient(
                            gradient: Gradient(colors: [Color.green, Color.green, Color.pink, Color.pink, Color.purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                }
            }
            .background(Color(.systemGray6)) // 전체 배경 색상 추가
        }
    }
}

struct PostView: View {
    let post: Post
    @State private var isShowingComments = false
    @State private var newComment = ""
    @State private var animateLike = false
    
    @EnvironmentObject var postViewModel: PostViewModel
    
    init(post: Post) {
        self.post = post
        self._animateLike = State(initialValue: post.likedBy.contains(Auth.auth().currentUser?.uid ?? ""))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 사용자 정보
            HStack {
                Image(systemName: "person.circle.fill") // 프로필 이미지 (임시)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.gray)
                
                Text(post.onwerUsername)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            .padding(.horizontal)
            
            // 게시물 이미지
            Image(post.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 300)
                .clipped()
                .cornerRadius(10)
            
            // 좋아요, 댓글, 채팅 버튼
            HStack(spacing: 20) {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        post.isLiked.toggle()
                        animateLike = post.isLiked
                    }
                }) {
                    Image(systemName: post.isLiked ? "heart.fill" : "heart")
                        .resizable()
                        .frame(width: 24, height: 22)
                        .foregroundColor(post.isLiked ? .red : .red)
                        .scaleEffect(animateLike ? 1.2 : 1.0) // 좋아요 애니메이션
                }
                
                Button(action: {
                    isShowingComments.toggle()
                }) {
                    Image(systemName: "message")
                        .resizable()
                        .frame(width: 22, height: 22)
                        .foregroundColor(.blue)
                }
                
                NavigationLink(destination: ChatView(username: post.username)) {
                    Image(systemName: "paperplane.fill")
                        .resizable()
                        .frame(width: 22, height: 22)
                        .foregroundColor(.green)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            
            // 댓글창
            if isShowingComments {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(post.comments, id: \.self) { comment in
                        Text(comment)
                            .font(.system(size: 14))
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .background(Color(.systemGray5))
                            .cornerRadius(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
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
                                post.comments.append(newComment)
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
    
    
    // 추가: 좋아요 토글
    private func toggleLike() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        animateLike.toggle()
        
        postViewModel.toggleLike(postId: post.id, userId: userId) { success in
            if !success {
                animateLike.toggle()
            }
        }
    }
}

// 추가: 스와이프 새로고침 컨트롤
struct RefreshControl: View {
    @Binding var isRefreshing: Bool
    let onRefresh: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            if geometry.frame(in: .global).minY > 50 {
                Spacer()
                    .onAppear() {
                        if !isRefreshing {
                            isRefreshing = true
                            onRefresh()
                        }
                    }
            } else if geometry.frame(in: .global).minY < 1 {
                Spacer()
                    .onAppear {
                        isRefreshing = false
                    }
            }
            
            HStack {
                Spacer()
                if isRefreshing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
                Spacer()
            }
        }.frame(height: isRefreshing ? 50 : 0)
    }
}

#Preview {
    HomeView()
}

