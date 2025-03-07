//
//  ContentView.swift
//  Buddygram
//
//  Created by KimJunsoo on 3/6/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab = 0
<<<<<<< HEAD
    @State private var posts: [FeedPost] = [
        FeedPost(username: "user1", image: "post1", isLiked: false),
        FeedPost(username: "user2", image: "post2", isLiked: false),
        FeedPost(username: "user3", image: "post3", isLiked: false)
    ]
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 홈
            HomeView(posts: $posts)
                .tabItem {
                    Image(systemName: "house.fill")
                }
                .tag(0)
            
            // 채팅 - 추후
             ChatListView()
                .tabItem {
                    Image(systemName: "paperplane.fill")
                }
                .tag(1)
            
            // 업로드
            UploadView()
                .tabItem {
                    Image(systemName: "plus.square.fill")
                }
                .tag(2)
                
            
            // 좋아요
            LikeView(posts: $posts)
                .tabItem {
                    Image(systemName: "heart.fill")
                }
                .tag(3)
            
            
            // 프로필
            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle.fill")
                }
                .tag(4)
            
=======
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                
                TabView(selection: $selectedTab) {
                    // 홈
                    HomeView()
                        .tabItem {
                            Image(systemName: "house.fill")
                        }
                        .tag(0)
                    
                    // 채팅 - 추후
                    // ChatView()
                    
                    // 업로드
                    UploadView()
                        .tabItem {
                            Image(systemName: "plus.square.fill")
                        }
                        .tag(1)
                    
                    
                    // 좋아요
                    LikeView()
                        .tabItem {
                            Image(systemName: "heart.fill")
                        }
                        .tag(2)
                    
                    
                    // 프로필
                    ProfileView()
                        .tabItem {
                            Image(systemName: "person.circle.fill")
                        }
                        .tag(3)
                    
                }
            } else {
                LoginView()
            }
>>>>>>> main
        }
        .environmentObject(authViewModel)
    }
    
}

#Preview {
    ContentView()
}
