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
            ZStack {
                Color(.systemGray6)
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    // 당겨서 새로고침
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
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 200, height: 50)
                                    .background(Color.green) // 앱 디자인에 맞게 변경
                                    .cornerRadius(12)
                            }
                        }
                    } else {
                        // UI에서 가져온 섹션 헤더 스타일
                        LazyVStack(alignment: .leading, pinnedViews: [.sectionHeaders]) {
                            Section(header: Text("❤️ 좋아요한 게시물")
                                .font(.title3)
                                .fontWeight(.bold)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemGray6))
                            ) {
                                ForEach(likedPosts) { post in
                                    LikedPostView(post: post)
                                }
                            }
                        }
                        .padding()
                    }
                }
                .refreshable {
                    await withCheckedContinuation { continuation in
                        postViewModel.fetchAllPosts {
                            continuation.resume()
                        }
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
                        .fontWeight(.semibold)
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
