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
    @Binding var posts: [FeedPost] // ContentView에서 데이터를 바인딩으로 받음

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach($posts) { $post in
                        PostView(post: $post) // 각 게시물을 PostView로 렌더링
                    }
                }
                .padding()
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
    }
}

struct PostView: View {
    @Binding var post: FeedPost
    @State private var isShowingComments = false // 댓글 창 표시 여부
    @State private var newComment = "" // 입력 중인 댓글

    var body: some View {
        VStack(alignment: .leading) {
            // 사용자 이름
            HStack {
                Text(post.username)
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)

            // 게시물 이미지
            Image(post.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 300)
                .clipped()

            // 좋아요, 댓글, 채팅 버튼
            HStack {
                // 좋아요 버튼
                Button(action: {
                    post.isLiked.toggle() // 좋아요 상태 변경
                }) {
                    Image(systemName: post.isLiked ? "heart.fill" : "heart")
                        .foregroundColor(post.isLiked ? .red : .red)
                }

                // 댓글 버튼
                Button(action: {
                    isShowingComments.toggle()
                }) {
                    Image(systemName: "message")
                        .foregroundColor(.green)
                }

                // 채팅 버튼
                NavigationLink(destination: ChatView(username: post.username)) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.green)
                }

                Spacer()
            }
            .padding(.horizontal)

            // 댓글창 (isShowingComments가 true일 때만 표시)
            if isShowingComments {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(post.comments, id: \.self) { comment in
                        Text(comment)
                            .padding(.vertical, 2)
                            .padding(.horizontal)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(5)
                    }

                    // 댓글 입력창
                    HStack {
                        TextField("댓글 입력...", text: $newComment)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        Button(action: {
                            if !newComment.isEmpty {
                                post.comments.append(newComment) // 댓글 추가
                                newComment = ""
                            }
                        }) {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(.black)
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
}


#Preview {
    HomeView(posts: .constant([
        FeedPost(username: "user1", image: "post1", isLiked: false),
        FeedPost(username: "user2", image: "post2", isLiked: true)
    ]))
}

