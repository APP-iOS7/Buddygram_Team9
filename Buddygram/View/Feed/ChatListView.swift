//
//  ChatListView.swift
//  Buddygram
//
//  Created by vKv on 3/7/25.
//

import SwiftUI

struct ChatListView: View {
    let users = ["user1", "user2", "user3"]
    
    var body: some View {
        NavigationView {
            List(users, id: \.self) { user in
                NavigationLink(destination: ChatView(username: user)) {
                    Text("\(user)님과의 채팅")
                }
            }
            .navigationTitle("메시지")
        }
    }
}

#Preview {
    ChatListView()
}
