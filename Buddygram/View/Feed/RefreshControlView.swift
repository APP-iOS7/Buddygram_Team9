//
//  RefreshControlView.swift
//  Buddygram
//
//  Created by KimJunsoo on 3/10/25.
//

import SwiftUI

// 당겨서 새로고침 컨트롤 (HomeView와 동일)
struct RefreshControl: View {
    @Binding var isRefreshing: Bool
    let onRefresh: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            if geometry.frame(in: .global).minY > 50 {
                Spacer()
                    .onAppear {
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
