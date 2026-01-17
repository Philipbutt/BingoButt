//
//  ContentView.swift
//  Bingo
//
//  Created by Philip Nasralla on 1/16/26.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var cardManager: CardManager
    @Binding var pendingCardData: BingoCardData?
    @StateObject private var bingoCard = BingoCard()
    @State private var showingSettings = false
    @State private var showingShareSheet = false
    @State private var shareItems: [Any] = []
    @State private var showingCardLimitAlert = false
    @State private var playMode = false
    
    init(cardManager: CardManager = CardManager(), pendingCardData: Binding<BingoCardData?> = .constant(nil)) {
        self.cardManager = cardManager
        _pendingCardData = pendingCardData
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Instructions
                    Text(playMode ? "Tap filled cells to mark them complete" : "Tap any box to add custom text")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top)
                    
                    // Bingo Card Display
                    BingoCardView(card: bingoCard, playMode: playMode)
                        .padding()
                    
                    // Action Buttons
                    VStack(spacing: 15) {
                        if playMode {
                            Button(action: {
                                withAnimation {
                                    playMode = false
                                }
                            }) {
                                HStack {
                                    Image(systemName: "pencil")
                                        .font(.title3)
                                    Text("Edit Card")
                                        .font(.headline)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.gradient)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                        } else {
                            Button(action: {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                    bingoCard.clearCard()
                                }
                            }) {
                                HStack {
                                    Image(systemName: "trash")
                                        .font(.title3)
                                    Text("Clear Card")
                                        .font(.headline)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange.gradient)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            
                            Button(action: {
                                if bingoCard.isCardFilled() {
                                    withAnimation {
                                        playMode = true
                                    }
                                } else {
                                    // Show alert that card needs to be filled
                                    let generator = UINotificationFeedbackGenerator()
                                    generator.notificationOccurred(.warning)
                                }
                            }) {
                                HStack {
                                    Image(systemName: "play.circle.fill")
                                        .font(.title3)
                                    Text("Play Card")
                                        .font(.headline)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(bingoCard.isCardFilled() ? Color.purple.gradient : Color.gray.gradient)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .disabled(!bingoCard.isCardFilled())
                        }
                        
                        Button(action: {
                            shareBingoCard()
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.title3)
                                Text("Share Card")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green.gradient)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Bingo Card Maker")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        saveCurrentCard()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "square.and.arrow.down")
                            Text("Save")
                                .font(.subheadline)
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingShareSheet) {
                if !shareItems.isEmpty {
                    ShareSheet(items: shareItems, isPresented: $showingShareSheet)
                }
            }
            .alert("Card Limit Reached", isPresented: $showingCardLimitAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("You can only save up to 6 cards. Please delete a card from 'My Cards' to save a new one.")
            }
        }
    }
    
    private func shareBingoCard() {
        // Create a shareable version of the card
        let shareView = BingoCardShareView(card: bingoCard)
        
        // Convert the view to an image
        let image = shareView.snapshot()
        
        // Create card data for deep linking
        let cardData = BingoCardData(
            id: bingoCard.id,
            grid: bingoCard.grid,
            dateCreated: Date()
        )
        
        // Encode card data to base64 string for URL
        guard let jsonData = try? JSONEncoder().encode(cardData),
              let base64String = jsonData.base64EncodedString().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            // Fallback to just sharing image if encoding fails
            shareItems = [image]
            showingShareSheet = true
            return
        }
        
        // Create deep link URL
        // Using a custom URL scheme that will be configured in Info.plist
        let deepLinkURL = URL(string: "bingocard://add?card=\(base64String)")!
        
        // Create share text with link
        let shareText = "Check out my Bingo Card! Tap the link to add it to your cards:\n\(deepLinkURL.absoluteString)\n\nOr get the app: https://apps.apple.com/app/bingo-card-maker"
        
        // Share both image and URL
        // The URL will be clickable in Messages, and clicking it will open the app
        shareItems = [
            shareText,
            image,
            deepLinkURL
        ]
        
        // Show the share sheet
        showingShareSheet = true
    }
    
    private func saveCurrentCard() {
        // Save current card to My Cards
        // Each save creates a new card (with new ID) so users can save multiple versions
        let success = cardManager.saveCard(bingoCard)
        
        if success {
            // Show success feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        } else {
            // Show limit reached alert
            showingCardLimitAlert = true
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
    }
}

#Preview {
    ContentView(cardManager: CardManager())
}