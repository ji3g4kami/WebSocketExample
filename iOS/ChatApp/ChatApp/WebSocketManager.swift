import SwiftUI
import Starscream

struct Message: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let senderID: String
}

struct ChatBubble: View {
    let message: Message
    let isCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isCurrentUser { Spacer() }
            Text(message.text)
                .padding(10)
                .background(isCurrentUser ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
            if !isCurrentUser { Spacer() }
        }
    }
}

class WebSocketManager: ObservableObject {
    @Published var messages: [Message] = []
    private var socket: WebSocket?
    let userID = UUID().uuidString
    
    init() {
        connectWebSocket()
    }
    
    func connectWebSocket() {
        let url = URL(string: "ws://localhost:8080/ws")!
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket?.delegate = self
        socket?.connect()
    }
    
    func sendMessage(_ text: String) {
        let message = ["text": text, "senderID": userID]
        if let data = try? JSONEncoder().encode(message) {
            socket?.write(data: data)
        }
    }
}

extension WebSocketManager: WebSocketDelegate {
    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        switch event {
        case .text(let string):
            if let data = string.data(using: .utf8),
               let message = try? JSONDecoder().decode([String: String].self, from: data) {
                DispatchQueue.main.async {
                    let newMessage = Message(text: message["text"] ?? "", senderID: message["senderID"] ?? "")
                    if !self.messages.contains(where: { $0.text == newMessage.text && $0.senderID == newMessage.senderID }) {
                        self.messages.append(newMessage)
                    }
                }
            }
        case .connected:
            print("WebSocket connected")
        case .disconnected(let reason, let code):
            print("WebSocket disconnected: \(reason) with code: \(code)")
        case .error(let error):
            print("WebSocket error: \(error?.localizedDescription ?? "Unknown error")")
        default:
            break
        }
    }
}
