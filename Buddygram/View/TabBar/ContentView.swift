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
                    // 여기에 탭 하나 추가해서 로그아웃되서 로그인 페이지 뷰로 가능 기능 넣어줘
                    
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
        }
        .environmentObject(authViewModel)
    }
    
}

#Preview {
    ContentView()
}
