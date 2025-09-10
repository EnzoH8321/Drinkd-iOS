//
//  WebSocketTests.swift
//  drinkd-iOSTests
//
//  Created by Enzo Herrera on 8/15/25.
//

import Testing
import Foundation
import Supabase
@testable import drinkd_iOS

@Suite("WebSocket Tests")
struct WebSocketTests {

    @Test("Create a channel")
    func setChannel_Test() async {
        let ws = WebSocket()
        let id = UUID(uuidString: "E921E1F2-C37C-495B-93FC-0C247A3E6E5F")!

        ws.setChannel(partyID: id)

        #expect(ws.channel.status == .unsubscribed)
    }

    @Test("Create a channel, subscribing & listen for messages")
    func rdbCreateChannel_Test() async {
        let ws = WebSocket()
        let vm = PartyViewModel()
        let id = UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")!

        await ws.rdbSetSubscribeAndListen(partyVM: vm, partyID: id)

        #expect(ws.channel.status == .subscribed || ws.channel.status == .unsubscribing)
    }

    @Test("Send a message" ,.timeLimit(.minutes(1)))
    func rdbSendMessage_Test() async {
        let ws = WebSocket()
        let partyID = UUID(uuidString: "E641E3F9-C36C-495A-93FC-0C847A9E6E5F")!
        let username = "Test001"
        let userID = UUID(uuidString: "A641E1F9-C36C-493A-93FC-0C247A3B6E5F")!
        let message = "Hello World!"
        let messageID = UUID(uuidString: "D641E1B9-C31C-493A-93FC-0C247A4B6E5F")!

        do {
            try await ws.stubSetupChannel(partyID: partyID)

            // Get Channel
            guard let channel = ws.channel else {
                Log.error.log("Channel not found")
                return
            }

            // Get Broadcast stream
            let stream = channel.broadcastStream(event: "newMessage")

            await ws.rdbSendMessage(userName: username, userID: userID, message: message, messageID: messageID, partyID: partyID)


            // Get latest Messages
            for await jsonObj in stream {

                guard let payload = jsonObj["payload"]?.value as? [String: Any] else {
                    Log.error.log("Unable to parse payload")
                    return
                }

                guard let pMessage = payload["message"] as? String else {
                    Log.error.log("Unable to parse message")
                    return
                }

                guard let username = payload["userName"] as? String else {
                    Log.error.log("Unable to parse username")
                    return
                }

                guard let idString = payload["messageID"] as? String, let pMessageID = UUID(uuidString: idString)  else {
                    Log.error.log("Unable to parse messageID")
                    return
                }

                guard let userIDString = payload["userID"] as? String, let pUserID = UUID(uuidString: userIDString)  else {
                    Log.error.log("Unable to parse userID")
                    return
                }


                #expect(pMessage == "Hello World!")
                #expect(username == "Test001")
                #expect(pMessageID == messageID)
                #expect(pUserID == userID)
                // For testing, we want to return after we receive the first value
                return
            }

        } catch {
            Issue.record("Error - \(error)")
        }
    }

    @Test("Listen for a message")
    func rdbListenForMessages_Test() async throws {
        let ws = WebSocket()
        let vm = PartyViewModel()
        let partyID = UUID(uuidString: "E641E1A9-C52A-495A-13FC-0C943A3E2E5F")!

        do {
            try await ws.stubSetupChannel(partyID: partyID)
            await ws.stubSendMessage(partyID: partyID)
            ws.rdbListenForMessages(partyVM: vm)
            // We suspend the task to ensure the broadcast stream has enough time to emit a message
            try await Task.sleep(for: .seconds(2))

            let message = try #require(vm.chatMessageList.first)
            #expect(message.username == "StubUser001")
            #expect(message.text == "Hello World!")
            #expect(message.userID == UUID(uuidString: "B641E3F9-C36C-493A-93FB-0C247A3B6E5F")!)
            #expect(message.id == UUID(uuidString: "D191E1B9-C31C-129A-93FC-0A247A4B6E5F")!)

        } catch {
            Issue.record("Error - \(error)")
        }

    }

    @Test("Cancel a websocket connection")
    func cancelWebSocketConnection_Test() async throws {
        let ws = WebSocket()
        let urlSession = URLSession(configuration: .default)
        let url = URL(string: "ws://example.com")!
        let webSocketTask = urlSession.webSocketTask(with: url)
        ws.websocketTask = webSocketTask

        ws.cancelWebSocketConnection()
        #expect(ws.websocketTask == nil)
    }
}

extension WebSocket {

    func stubSetupChannel(partyID: UUID) async throws {
        setChannel(partyID: partyID)

        do {
            try await self.channel?.subscribeWithError()
        } catch {
            throw TestError.wsError
        }
    }

    func stubSendMessage(partyID: UUID) async {

        let username = "StubUser001"
        let userID = UUID(uuidString: "B641E3F9-C36C-493A-93FB-0C247A3B6E5F")!
        let message = "Hello World!"
        let messageID = UUID(uuidString: "D191E1B9-C31C-129A-93FC-0A247A4B6E5F")!

        if let channel = self.channel {

            do {

                try await channel.broadcast(
                    event: "newMessage",
                    message: [
                        "message": message,
                        "userID": userID.uuidString,
                        "userName": username,
                        "messageID": messageID.uuidString
                    ]
                )

            } catch {
                Log.error.log("Error in rdbSendMessage - \(error)")
            }

        }
    }
}

