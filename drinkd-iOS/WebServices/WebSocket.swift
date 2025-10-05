//
//  WebSocket.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 8/2/25.
//

import Foundation
import drinkdSharedModels
import Realtime
import Supabase

@Observable
final class WebSocket: NSObject, URLSessionWebSocketDelegate {

    private(set) var client: SupabaseClient!

    var websocketTask:  URLSessionWebSocketTask? = nil

    private(set) var channel: RealtimeChannelV2!

    override init() {
        super.init()
        // The Publishable Key is safe to use as long as RLS is enabled for tables and the correct policies have been set.
        guard let supabaseKey = Bundle.main.infoDictionary?["SUPABASE_PUBLISHABLE_KEY"] as? String else {
            fatalError("Unable to retrieve the publishable supabase key")
        }

        guard let supabaseURL = URL(string: "https://jdkdtahoqpsspesqyojb.supabase.co") else {
            fatalError("Invalid Supabase URL")
        }

        self.client = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: supabaseKey
        )

    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("Web Socket did connect")
        ping()
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("Web Socket did disconnect")
        ping()
    }

    /// Sets up websocket channel for the specified party
    /// - Parameter partyID: UUID of the party to connect to
    func setChannel(partyID: UUID) {
        self.channel = client.channel(partyID.uuidString) {
            $0.broadcast.receiveOwnBroadcasts = true
        }
    }

    /// Cancels the active WebSocket connection if one exists
    func cancelWebSocketConnection() {
        // Exit early if no WebSocket connection exists
        guard websocketTask != nil else {
            Log.error.log("Websocket is nil")
            return
        }

        Log.error.log("Closing websocket connection")
        let reason = "Closing connection".data(using: .utf8)
        websocketTask?.cancel(with: .goingAway, reason: reason)
        websocketTask = nil
    }

    /// Sends a ping to check WebSocket connection health and schedules the next ping
    func ping() {
        // Ensure WebSocket task exists before attempting ping
        guard let webSocketTask = self.websocketTask else {
            Log.error.log("Error: No WebSocket task")
            return
        }
        // Send ping and handle response
        webSocketTask.sendPing { error in
            if let error = error {
                Log.error.log("Error when sending PING \(error)")
            } else {
                Log.general.log("Web Socket connection is alive")
                DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
                    self.ping()
                }
            }
        }
    }

    /// Subscribes to a channel and listens for messages
    /// - Parameters:
    ///   - partyVM: Party view model
    ///   - partyID: UUID of the party to subscribe to
    func rdbSetSubscribeAndListen(partyVM: PartyViewModel, partyID: UUID) async {

        setChannel(partyID: partyID)

        do {
            // Subscribe to channel and start listening for messages
            try await self.channel?.subscribeWithError()
            rdbListenForMessages(partyVM: partyVM)
        } catch {
            Log.error.log("rdbCreateChannel error: \(error)")
        }

        Log.general.log("New Channel - \(self.channel)")
    }

    /// Sends a chat message to the party channel via real-time database broadcast
    /// - Parameters:
    ///   - userName: Username of the message sender
    ///   - userID: Users UUID
    ///   - message: Text content of the message
    ///   - messageID: UUID for this message
    ///   - partyID: UUID of the party receiving the message
    func rdbSendMessage(userName: String, userID: UUID, message: String, messageID: UUID, partyID: UUID) async {

        if let channel = self.channel {

            do {
                // Broadcast message
                try await channel.broadcast(
                    event: "newMessage",
                    message: [
                        "message": message,
                        "userID": userID.uuidString,
                        "userName": userName,
                        "messageID": messageID.uuidString
                    ]
                )

            } catch {
                Log.error.log("Error in rdbSendMessage - \(error)")
            }

        }
    }

    /// Listens for incoming messages and updates the chat list
    /// - Parameters:
    ///   - partyVM: Party view model
    func rdbListenForMessages(partyVM: PartyViewModel) {

        // Get Channel
        guard let channel = self.channel else {
            Log.error.log("Channel not found")
            return
        }

        // Get Broadcast stream
        let stream = channel.broadcastStream(event: "newMessage")

        Task {
            // Get latest Messages
            for await jsonObj in stream {

                guard let payload = jsonObj["payload"]?.value as? [String: Any] else {
                    Log.error.log("Unable to parse payload")
                    return
                }

                guard let message = payload["message"] as? String else {
                    Log.error.log("Unable to parse message")
                    return
                }

                guard let username = payload["userName"] as? String else {
                    Log.error.log("Unable to parse username")
                    return
                }

                guard let idString = payload["messageID"] as? String, let messageID = UUID(uuidString: idString) else {
                    Log.error.log("Unable to parse messageID")
                    return
                }

                guard let userIDString = payload["userID"] as? String, let userID = UUID(uuidString: userIDString) else {
                    Log.error.log("Unable to parse userID")
                    return
                }


                let wsMessage = WSMessage(id: messageID, text: message, username: username, timestamp: Date.now, userID: userID)
                partyVM.chatMessageList.append(wsMessage)
                
            }

            Log.general.log("TASK DONE")
        }
    }

    /// Executes an async operation with a timeout, throwing an error if time limit is exceeded
    /// - Parameters:
    ///   - seconds: Maximum time to wait before timing out
    ///   - operation: Async operation to execute with timeout
    /// - Returns: Result of the operation if completed within timeout
    /// - Throws: Operation error or timeout error if time limit exceeded
//    private func withTimeout<T>(seconds: TimeInterval, operation: @escaping () async throws -> T) async throws -> T {
//        return try await withThrowingTaskGroup(of: T.self) { group in
//            // Add the main operation task
//            group.addTask {
//                try await operation()
//            }
//
//            // Add timeout task that throws after specified duration
//            group.addTask {
//                try await Task.sleep(for: .seconds(seconds))
//                throw SharedErrors.general(error: .generalError("Timeout Hit"))
//            }
//
//            // Return first completed result and cancel remaining tasks
//            defer { group.cancelAll() }
//            return try await group.next()!
//        }
//    }


}
