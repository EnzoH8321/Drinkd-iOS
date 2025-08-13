//
//  MessageView.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 12/17/21.
//

import SwiftUI
import drinkdSharedModels

struct MessageView: View {
    
    var username: String
    var message: String
    var messageUserID: UUID
    var timestamp: Date

    //Check to see if the message was written by the user.
    private var isMyMessage: Bool {
        do {
            let currentID = try UserDefaultsWrapper.getUserID
            return currentID == messageUserID ? true : false
        } catch {
            return false
        }

    }

    private var timeString: String {
        return timestamp.monthDay
    }

    var body: some View {
        
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill( isMyMessage ? AppColors.primaryColor : Color(red: 230/255, green: 230/255, blue: 230/255))
            
            VStack(alignment: .leading) {
                
                HStack(alignment: .bottom) {
                    Text("\(username)")
                        .bold()
                        .padding([.leading, .top])

                    Spacer()

                    Text(timeString)
                        .font(.caption)
                        .padding([.trailing])
                        .italic()
                }
                
                Text("\(message)")
                    .padding([.leading, .bottom, .trailing])
            }
            .foregroundColor(isMyMessage ? .white : .black)
            
        }
        .padding([.leading], isMyMessage ? 105 : 20)
        .padding([.trailing], isMyMessage ? 20 : 105)
        
    }
}

#Preview("MyMessages") {
    do {
        let userID = try UserDefaultsWrapper.getUserID
        return MessageView(username: "User101", message: "Hello World!", messageUserID: userID, timestamp: Date())
    } catch {
        return Text("Error")
    }
}

#Preview("Other Peoples Messages") {
    MessageView(username: "User101", message: "Hellow World!", messageUserID: UUID(), timestamp: Date())
}

