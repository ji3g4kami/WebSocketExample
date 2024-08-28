import Foundation
import Starscream

class WebSocketManager: ObservableObject {
    @Published var messages: [String] = []
    private var socket: WebSocket?
    
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
    
    func sendMessage(_ message: String) {
        socket?.write(string: message)
    }
}

extension WebSocketManager: WebSocketDelegate {
    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        
        switch event {
        case .text(let string):
            DispatchQueue.main.async {
                self.messages.append(string)
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
