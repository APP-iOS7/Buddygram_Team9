//
//  ContentView.swift
//  Buddygram
//
//  Created by KimJunsoo on 3/6/25.
//

import SwiftUI
import SwiftData
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Kingfisher

struct ContentView: View {
    @State private var selectedTab = 0
    
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var postViewModel = PostViewModel()
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                TabView(selection: $selectedTab) {
                    // 홈
                    HomeView(selectedTab: $selectedTab)
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
                    UploadView(selectedTab: $selectedTab)
                        .tabItem {
                            Image(systemName: "plus.square.fill")
                        }
                        .tag(2)
                    
                    
                    // 좋아요
                    LikeView(selectedTab: $selectedTab)
                        .tabItem {
                            Image(systemName: "heart.fill")
                        }
                        .tag(3)
                    
                    
                    // 프로필
                    ProfileView(selectedTab: $selectedTab)
                        .tabItem {
                            Image(systemName: "person.circle.fill")
                        }
                        .tag(4)
                }
                
            } else {
                LoginView()
            }
        }
        .environmentObject(authViewModel)
        .environmentObject(postViewModel)
        .onChange(of: authViewModel.isAuthenticated) { oldValue, newValue in
            if !newValue {
                selectedTab = 0
            } else if newValue && oldValue == false {
                postViewModel.fetchAllPosts()
                
                if let user = authViewModel.currentUser {
                    let db = Firestore.firestore()
                    db.collection("users").document(user.id).getDocument { (document, error) in
                        if let document = document, document.exists {
                            let data = document.data()
                            
                            if data?["firstLogin"] as? Bool != false {
                                postViewModel.createWelcomePost(for: user)
                                
                                db.collection("users").document(user.id).updateData(["firstLogin": false])
                            }
                        }
                        
                    }
                    
                }
            }
        }
        .onAppear {
            // Kingfisher 이미지 캐시 설정
            let cache = ImageCache.default
            cache.memoryStorage.config.totalCostLimit = 100 * 1024 * 1024
            cache.diskStorage.config.sizeLimit = 300 * 1024 * 1024
        }
    }
    
}

#Preview {
    ContentView()
}
