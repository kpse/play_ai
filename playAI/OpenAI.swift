import Foundation

struct ChatCompletionResponse: Codable {
    struct Choice: Codable {
        struct Message: Codable {
            let role: String
            let content: String
        }

        let message: Message
        let finish_reason: String
        let index: Int
    }

    let id: String
    let object: String
    let created: Int
    let model: String
    let usage: [String: Int]
    let choices: [Choice]
}
struct Message {
    var text: String
    var isMe: Bool
}

func getAPIKey() -> String? {
    if let path = Bundle.main.path(forResource: "Keys", ofType: "plist"),
       let keysDictionary = NSDictionary(contentsOfFile: path) as? [String: AnyObject],
       let apiKey = keysDictionary["API_KEY"] as? String {
        return apiKey
    }
    return nil
}

func fetchCompletion(messages: [Message], completionHandler: @escaping (Result<ChatCompletionResponse, Error>) -> Void) {
    guard let apiKey = getAPIKey() else {
        print("Error: Failed to read API key from Keys.plist")
        return
    }
    print(apiKey)
    let url = URL(string: "https://api.openai.com/v1/chat/completions")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let messageObjects = messages.map { ["role": $0.isMe ? "user" : "system", "content": $0.text] }
    let requestBody: [String: Any] = [
        "model": "gpt-3.5-turbo",
        "messages": messageObjects,
        "max_tokens": 50
    ]

    do {
        let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
        request.httpBody = jsonData
    } catch {
        completionHandler(.failure(error))
        return
    }

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completionHandler(.failure(error))
            return
        }

        guard let data = data else {
            completionHandler(.failure(NSError(domain: "NoDataError", code: -1, userInfo: nil)))
            return
        }
        print(String(data: data, encoding: .utf8) ?? "Unable to convert data to text")

        do {
            let decoder = JSONDecoder()
            let chatCompletionResponse = try decoder.decode(ChatCompletionResponse.self, from: data)
            completionHandler(.success(chatCompletionResponse))
        } catch {
            completionHandler(.failure(error))
        }
    }

    task.resume()
}
