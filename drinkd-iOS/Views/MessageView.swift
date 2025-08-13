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
            
            VStack(alignment: .leading, spacing: 10) {
                
                HStack(alignment: .bottom) {
                    Text("\(username)")
                        .bold()
                        .padding([.leading, .top], 10)
                    
                    Text(timeString)
                        .padding([.leading], 30)
                    
                    Spacer()
                }
                
                Text("\(message)")
                    .padding([.leading, .bottom], 10)
            }
            .foregroundColor(isMyMessage ? .white : .black)
            
        }
        .padding([.leading], isMyMessage ? 105 : 20)
        .padding([.trailing], isMyMessage ? 20 : 105)
        
    }
}

#Preview {
    MessageView(username: "User101", message: "Hellow World!", messageUserID: UUID(), timestamp: Date())
}

