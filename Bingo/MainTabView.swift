//
//  MainTabView.swift
//  Bingo
//
//  Created by Philip Nasralla on 1/16/26.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var cardManager = CardManager()
    @State private var selectedTab = 0
    @State private var pendingCardData: BingoCardData?
    @State private var showingCardLimitAlert = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ContentView(cardManager: cardManager, pendingCardData: $pendingCardData)
                .tabItem {
                    Label("Create", systemImage: "plus.circle.fill")
                }
                .tag(0)
            
            MyCardsView(cardManager: cardManager)
                .tabItem {
                    Label("My Cards", systemImage: "square.grid.3x3.fill")
                }
                .tag(1)
        }
        .onOpenURL { url in
            handleDeepLink(url: url)
        }
        .alert("Card Limit Reached", isPresented: $showingCardLimitAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("You can only save up to 6 cards. Please delete a card from 'My Cards' to save a new one.")
        }
    }
    
    private func handleDeepLink(url: URL) {
        // Handle both custom URL schemes
        guard url.scheme == "bingocard" || url.scheme == "bingocardmaker" else { return }
        
        // Check if URL path contains "add" or host is "add"
        if url.host == "add" || url.path.contains("add") || url.absoluteString.contains("card=") {
            // Parse card data from URL query parameters
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let queryItems = components.queryItems,
               let cardDataString = queryItems.first(where: { $0.name == "card" })?.value,
               let decodedString = cardDataString.removingPercentEncoding,
               let cardData = decodeCardData(from: decodedString) {
                // Switch to My Cards tab and add the card
                selectedTab = 1
                let success = cardManager.addCardFromData(cardData)
                if !success {
                    showingCardLimitAlert = true
                }
            }
        }
    }
    
    private func decodeCardData(from base64String: String) -> BingoCardData? {
        guard let data = Data(base64Encoded: base64String),
              let cardData = try? JSONDecoder().decode(BingoCardData.self, from: data) else {
            return nil
        }
        return cardData
    }
}

#Preview {
    MainTabView()
}
