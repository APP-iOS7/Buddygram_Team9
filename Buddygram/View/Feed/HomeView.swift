//
//  HomeView.swift
//  Buddygram
//
//  Created by KimJunsoo on 3/6/25.
//

import SwiftUI

struct FeedPost: Identifiable {
    let id = UUID()
    let username: String
    let image: String
    var isLiked: Bool
    var comments: [String] = []
}

import SwiftUI

struct HomeView: View {
    @Binding var posts: [FeedPost]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 15) {
                    ForEach($posts) { $post in
                        PostView(post: $post)
                    }
                }
                .padding(.horizontal)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Buddygram")
                        .font(.largeTitle)
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
    @Binding var post: FeedPost
    @State private var isShowingComments = false
    @State private var newComment = ""
    @State private var animateLike = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 사용자 정보
            HStack {
                Image(systemName: "person.circle.fill") // 프로필 이미지 (임시)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.gray)
                
                Text(post.username)
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
                        .foregroundColor(.black)
                }

                NavigationLink(destination: ChatView(username: post.username)) {
                    Image(systemName: "paperplane.fill")
                        .resizable()
                        .frame(width: 22, height: 22)
                        .foregroundColor(.green)
                }

                Spacer()
                    .padding()
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
}


#Preview {
    HomeView(posts: .constant([
        FeedPost(username: "user1", image: "post1", isLiked: false),
        FeedPost(username: "user2", image: "post2", isLiked: true)
    ]))
}

