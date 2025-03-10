//
//  LikeView.swift
//  Buddygram
//
//  Created by KimJunsoo on 3/6/25.
//

import SwiftUI
import Firebase
import FirebaseAuth
import Kingfisher

struct LikeView: View {
    @Binding var selectedTab: Int
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var postViewModel: PostViewModel
    @State private var isRefreshing = false
    
    // 좋아요한 게시물 필터링
    var likedPosts: [Post] {
        guard let userId = Auth.auth().currentUser?.uid else { return [] }
        return postViewModel.posts.filter { post in
            post.likedBy.contains(userId)
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                // Pull to refresh
                RefreshControl(isRefreshing: $isRefreshing) {
                    postViewModel.fetchAllPosts {
                        isRefreshing = false
                    }
                }
                
                if postViewModel.isLoading && !isRefreshing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding(.top, 50)
                } else if likedPosts.isEmpty {
                    VStack(spacing: 20) {
                        Text("아직 좋아요한 게시물이 없습니다.")
                            .font(.headline)
                            .padding(.top, 100)
                        
                        Button(action: {
                            selectedTab = 0
                        }) {
                            Text("홈으로 돌아가기")
                                .font(.system(size: btnFontSize, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 200, height: btnHeight)
                                .background(Color("PrimaryButtonColor"))
                                .cornerRadius(btnCornerRadius)
                        }
                    }
                } else {
                    LazyVStack(spacing: 20) {
                        ForEach(likedPosts) { post in
                            LikedPostView(post: post)
                        }
                    }
                    .padding()
                }
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
                    Text("❤️ 좋아요한 게시물")
                        .font(.headline)
                        .foregroundColor(.red)
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

struct LikedPostView: View {
    let post: Post
    
    @EnvironmentObject var postViewModel: PostViewModel
    @State private var isLiked = true
    
    var body: some View {
        NavigationLink(destination: PostDetailView(post: post)) {
            VStack(alignment: .leading) {
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
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(post.createdAt, style: .date)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                
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
                
                // 캡션 (간단히 표시)
                if let caption = post.caption {
                    Text(caption)
                        .lineLimit(2)
                        .padding(.horizontal)
                        .padding(.top, 4)
                        .foregroundColor(.primary)
                }
                
                // 좋아요 개수 표시
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                    
                    Text("\(post.likeCount) 명이 좋아합니다")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 4)
            }
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
            .padding(.horizontal)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
