//
//  WebSocket.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 8/2/25.
//

import Foundation
import drinkdSharedModels

@Observable
final class WebSocket: NSObject, URLSessionWebSocketDelegate {

    static let shared = WebSocket()

    private var session: URLSession!

    var websocketTask:  URLSessionWebSocketTask? = nil

    private override init() {
        super.init()
        self.session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("Web Socket did connect")
        ping()
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("Web Socket did disconnect")
        ping()
    }

    func connectToWebsocket(partyVM: PartyViewModel, username: String, userID: UUID, partyID: UUID) async {

        do {

            let url = URL(string: "ws://localhost:8080/testWS/\(username)/\(userID.uuidString)/\(partyID.uuidString)")!

            self.websocketTask = URLSession.shared.webSocketTask(with: url)
            self.websocketTask?.resume()

            guard let websocket = websocketTask else {
                Log.general.error("Websocket task is nil")
                return
            }


            try await withTimeout(seconds: 5) {

                self.receiveWebsocket(task: websocket, partyVM: partyVM)

            }

        } catch {
            Log.networking.error("Error connecting to WebSocket - \(error)")
        }

    }

    func receiveWebsocket(task: URLSessionWebSocketTask, partyVM: PartyViewModel) {
        task.receive { result in

            switch result {
            case .success(let success):
                // Get existing messages from party during initialization
                Task {
                    try await Networking.shared.getMessages(viewModel: partyVM)
                }

                do {
                    switch success {

                    case .data(let data):

                        do {
                            let message = try JSONDecoder().decode(WSMessage.self, from: data)
                            partyVM.chatMessageList.append(message)
                        } catch {
                            Log.networking.error("Error decoding websocket binary data - \(error)")
                        }
                    case .string(let string):
                        Log.general.info("Websocket received string - \(string)")
                    }

                }

            case .failure(let failure):
                Log.general.error("Error connecting to websocket - \(failure)")
            }

            self.receiveWebsocket(task: task, partyVM: partyVM)
        }
    }

    func cancelWebSocketConnection() {

        guard websocketTask != nil else {
            Log.networking.error("Websocket is nil")
            return
        }

        Log.general.info("Closing websocket connection")
        let reason = "Closing connection".data(using: .utf8)
        websocketTask?.cancel(with: .goingAway, reason: reason)
        websocketTask = nil
    }

    func ping() {
        guard let webSocketTask = self.websocketTask else {
            Log.general.error("Error: No WebSocket task")
            return
        }

        webSocketTask.sendPing { error in
            if let error = error {
                print("Error when sending PING \(error)")
            } else {
                print("Web Socket connection is alive")
                DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
                    self.ping()
                }
            }
        }
    }

    private func withTimeout<T>(seconds: TimeInterval, operation: @escaping () async throws -> T) async throws -> T {
        return try await withThrowingTaskGroup(of: T.self) { group in
            // Add the main operation
            group.addTask {
                try await operation()
            }

            // Add timeout task
            group.addTask {
                try await Task.sleep(for: .seconds(seconds))
                throw SharedErrors.general(error: .generalError("Timeout Hit"))
            }

            // Return the first result and cancel other tasks
            defer { group.cancelAll() }
            return try await group.next()!
        }
    }


}
