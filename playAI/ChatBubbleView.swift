//
//  ChatBubbleView.swift
//  playAI
//
//  Created by Louis Suo on 18/3/2023.
//

import SwiftUI

struct ChatBubbleView: View {
    var message: String
    var isMe: Bool

    var body: some View {
        HStack {
            if isMe {
                Spacer()
            }
            Text(message)
                .padding()
                .foregroundColor(.white)
                .background(isMe ? Color.blue : Color.gray)
                .cornerRadius(16)
            if !isMe {
                Spacer()
            }
        }
    }
}
