//
//  ContentView.swift
//  API Calls
//
//  Created by Khalmatov on 21.08.2023.
//

import SwiftUI
struct ContentView: View {
    
    @State private var user: GitHubUser?
    
    var body: some View {
        VStack(spacing: 20) {
            AsyncImage(url: URL(string: user?.avatarUrl ?? ""), content: { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
            }, placeholder: {
                Circle()
                    .foregroundColor(.secondary)
            })
                .frame(width: 120, height: 120)
            Text(user?.login ?? "Username Placeholder")
                .bold()
                .font(.title3)
            Text(user?.bio ?? "Bio placeholder")
                .padding()
            Spacer()
        }
        .padding()
        .task {
            do {
                user = try await getUser()
            } catch APCError.invalidData {
                print("invalid data")
            } catch APCError.invalidResponce {
                print("invalid response")
            } catch APCError.invalidUrl {
                print("invalid url")
            } catch {
                print("unexpected error")
            }
        }
    
    }
 
}

extension ContentView {
    func getUser() async throws -> GitHubUser {
        let endPoint = "https://api.github.com/users/IsmoilXolmatov"
        guard let url = URL(string: endPoint) else {
            throw APCError.invalidUrl
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw APCError.invalidResponce
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(GitHubUser.self, from: data)
        } catch {
            throw APCError.invalidData
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


struct GitHubUser: Codable {
    let login: String
    let avatarUrl: String
    let bio: String
    
}

enum APCError: Error {
    case invalidUrl
    case invalidResponce
    case invalidData
}
