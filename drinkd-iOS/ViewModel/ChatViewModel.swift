//
//  ChatViewModel.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 4/30/25.
//

import Foundation
import drinkdSharedModels

@Observable
final class ChatViewModel {
    var personalUserName = ""
    var personalUserID: UUID? 
    var chatMessageList: [WSMessage] = []

    //For chat
    //TODO: Finish Chat Features
    func setPersonalUserAndID(forName name: String, forID id: UUID) {
        self.personalUserName = name
        self.personalUserID = id
    }
}
