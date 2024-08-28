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
            List(webSocketManager.messages, id: \.self) { message in
                Text(message)
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
        .onAppear {
            webSocketManager.connectWebSocket()
        }
    }
    
    func sendMessage() {
        guard !inputMessage.isEmpty else { return }
        webSocketManager.sendMessage(inputMessage)
        inputMessage = ""
    }
}

#Preview {
    ContentView()
}
