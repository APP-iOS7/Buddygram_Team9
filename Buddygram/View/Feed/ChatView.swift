//
//  ChatView.swift
//  Buddygram
//
//  Created by vKv on 3/7/25.
//

import SwiftUI

struct ChatView: View {
    let username: String
    @State private var messageText: String = ""
    @State private var messages: [(text: String, isMe: Bool)] = [
        ("Hello!", false),
        ("안녕하세요!", true)
    ]
    
    var body: some View {
        ZStack {
            // 배경
//            Color.green.opacity(0.2)
//                .edgesIgnoringSafeArea(.all)
            
        
            VStack {
                
                Text("\(username)님과의 채팅")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding()
                
                // 채팅 메시지 리스트
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(messages.indices, id: \.self) { index in
                            MessageBubble(text: messages[index].text, isMe: messages[index].isMe)
                        }
                    }
                    .padding()
                }
                
                // 입력창 & 전송 버튼
                HStack {
                    TextField("메시지를 입력하세요...", text: $messageText)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(20)
                        .shadow(radius: 3)
                    
                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color(red: 0.4, green: 0.8, blue: 0.2))
                            .clipShape(Circle())
                    }
                }
                .padding()
            }
//            .background(Color.white)
//            .cornerRadius(20)
//            .overlay(RoundedRectangle(cornerRadius: 20)
//                .stroke(Color.green,lineWidth:2))
        }
                
    }
    
    
    // 메시지 전송 함수
    func sendMessage() {
        if !messageText.isEmpty {
            messages.append((text: messageText, isMe: true))
            messageText = ""
        }
    }
}

// 말풍선 디자인 (보낸 메시지, 받은 메시지 구분)
struct MessageBubble: View {
    let text: String
    let isMe: Bool
    
    var body: some View {
        HStack {
            if isMe { Spacer() } // 보낸 메시지는 오른쪽 정렬
            
            Text(text)
                .padding()
                .background(isMe ? Color(red: 0.4, green: 0.8, blue: 0.2) : Color(red: 0.8, green: 0.3, blue: 0.8))
                .foregroundColor(isMe ? .white : .white)
                .cornerRadius(15)
                .shadow(radius: 2)
            
            if !isMe { Spacer() } // 받은 메시지는 왼쪽 정렬
        }
        .padding(.horizontal, 10)
    }
}

#Preview {
    ChatView(username: "user1")
}
