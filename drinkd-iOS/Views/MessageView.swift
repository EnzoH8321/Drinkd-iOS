//
//  MessageView.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 12/17/21.
//

import SwiftUI

struct MessageView: View {
    
    var username: String
    var message: String
    var messageChatID: Int
    var personalChatId: Int
    var timestampString: String
    
    //Check to see if the message was written by the user.
    var isMyMessage: Bool {
        if (messageChatID == personalChatId) {
            return true
        } else {
            return false
        }
    }
    
    var body: some View {
        
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .fill( isMyMessage ? AppColors.primaryColor : Color(red: 230/255, green: 230/255, blue: 230/255))
            
            VStack(alignment: .leading, spacing: 10) {
                
                HStack(alignment: .bottom) {
                    Text("\(username)")
                        .bold()
                        .padding([.leading, .top], 10)
                    
                    Text("\(timestampString)")
                        .padding([.leading], 30)
                    
                    Spacer()
                }
                
                Text("\(message)")
                    .padding([.leading, .bottom], 10)
            }
            .foregroundColor(isMyMessage ? .white : .black)
            
        }
        .padding([.leading], isMyMessage ? 65 : 30)
        .padding([.trailing], isMyMessage ? 30 : 65)
        
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView(username: "Enzo", message: "CHAT FEATURES WORKS", messageChatID: 4545454, personalChatId: 4545454, timestampString: "Dfdfd")
    }
}

