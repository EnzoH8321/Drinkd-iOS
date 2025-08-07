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

    private var client: SupabaseClient!

    static let shared = WebSocket()

    private var session: URLSession!

    var websocketTask:  URLSessionWebSocketTask? = nil

    private var channel: RealtimeChannelV2!

    private override init() {
        super.init()
        self.session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())

        let supabaseKey = Constants.supabaseToken

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

    func cancelWebSocketConnection() {

        guard websocketTask != nil else {
            Log.error.log("Websocket is nil")
            return
        }

        Log.error.log("Closing websocket connection")
        let reason = "Closing connection".data(using: .utf8)
        websocketTask?.cancel(with: .goingAway, reason: reason)
        websocketTask = nil
    }

    func ping() {
        guard let webSocketTask = self.websocketTask else {
            Log.error.log("Error: No WebSocket task")
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

    // Creates channel, partyID should be the channel identifier
    // Only use when creating party
    func rdbCreateChannel(partyVM: PartyViewModel, partyID: UUID) async {

        self.channel = client.channel(partyID.uuidString) {
            $0.broadcast.receiveOwnBroadcasts = true
        }

        do {
            try await self.channel?.subscribeWithError()
            rdbListenForMessages(partyVM: partyVM ,partyID: partyID.uuidString)
        } catch {
            Log.error.log("rdbCreateChannel error: \(error)")
        }


        Log.general.log("New Channel - \(self.channel)")
    }

    func rdbSendMessage(userName: String, userID: UUID, message: String, messageID: UUID, partyID: UUID) async {

        if let channel = self.channel {

            do {

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

   private func rdbListenForMessages(partyVM: PartyViewModel, partyID: String) {

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

                guard let idString = payload["messageID"] as? String, let messageID = UUID(uuidString: idString)  else {
                    Log.error.log("Unable to parse messageID")
                    return
                }

                guard let userIDString = payload["userID"] as? String, let userID = UUID(uuidString: userIDString)  else {
                    Log.error.log("Unable to parse userID")
                    return
                }


                let wsMessage = WSMessage(id: messageID, text: message, username: username, timestamp: Date.now, userID: userID)
                partyVM.chatMessageList.append(wsMessage)

            }

            Log.general.log("TASK DONE")
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
