//
//  ContentView.swift
//  ChatApp
//
//  Created by 登秝吳 on 28/08/2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var webSocketManager = WebSocketManager()
    @State private var inputMessage = ""
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 10) {
                    ForEach(webSocketManager.messages) { message in
                        ChatBubble(message: message, isCurrentUser: message.senderID == webSocketManager.userID)
                    }
                }
                .padding()
            }
            
            HStack {
                TextField("Enter message", text: $inputMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Send") {
                    sendMessage()
                }
            }
            .padding()
        }
    }
    
    func sendMessage() {
        guard !inputMessage.isEmpty else { return }
        webSocketManager.sendMessage(inputMessage)
        inputMessage = ""
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
