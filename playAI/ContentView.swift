import SwiftUI
import Foundation

struct ContentView: View {
    @State private var question = ""
    @State private var messages: [Message] = [Message(text: "You are a helpful assistant.", isMe: false)]

    func sendMessage() {
        messages.append(Message(text: question, isMe: true))
        question = ""
        
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now()) {
            fetchCompletion(messages: messages) { result in
                switch result {
                case .success(let chatCompletionResponse):
                    let responseText = chatCompletionResponse.choices.first?.message.content ?? ""
                    DispatchQueue.main.async {
                        messages.append(Message(text: responseText, isMe: false))
                    }
                case .failure(let error):
                    print("Error: \(error)")
                    DispatchQueue.main.async {
                        // Handle the error, update UI, or show an error message
                    }
                }
            }
        }
    }

    var body: some View {
        VStack {
            ScrollView {
                ForEach(messages.indices, id: \.self) { index in
                    ChatBubbleView(message: messages[index].text, isMe: messages[index].isMe)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 10)

            HStack {
                TextField("Ask a question...", text: $question, onCommit: sendMessage)
                    .padding(.horizontal)
                    .foregroundColor(.black)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(radius: 5)
                
                Button(action: sendMessage, label: {
                    Text("Send")
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .cornerRadius(16)
                })
                .padding(.trailing)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color.gray.opacity(0.1).ignoresSafeArea())
        .onAppear {
            if let window = NSApplication.shared.windows.first {
                window.title = "ChatGPT"
            }
        }
    }
}


