//
//  MyCardsView.swift
//  Bingo
//
//  Created by Philip Nasralla on 1/16/26.
//

import SwiftUI

struct MyCardsView: View {
    @ObservedObject var cardManager: CardManager
    @State private var selectedCard: BingoCardData?
    @State private var showingCardDetail = false
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            Group {
                if cardManager.savedCards.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "square.grid.3x3")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("No Cards Yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Share a card or create one to get started")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 16) {
                            ForEach(cardManager.savedCards) { cardData in
                                CardThumbnailView(cardData: cardData)
                                    .onTapGesture {
                                        selectedCard = cardData
                                        showingCardDetail = true
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("My Cards")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("\(cardManager.savedCards.count)/6 Cards")
                        .font(.caption)
                        .foregroundColor(.secondary)
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
            .sheet(item: $selectedCard) { cardData in
                CardDetailView(cardData: cardData, cardManager: cardManager)
            }
        }
    }
}

struct CardThumbnailView: View {
    let cardData: BingoCardData
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 2) {
                ForEach(["B", "I", "N", "G", "O"], id: \.self) { letter in
                    Text(letter)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 20)
                        .background(getColorForLetter(letter))
                }
            }
            
            // Grid preview
            VStack(spacing: 0) {
                ForEach(0..<5, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<5, id: \.self) { column in
                            let value = cardData.grid[row][column]
                            let isFree = row == 2 && column == 2
                            
                            Text(isFree ? "FREE" : (value.isEmpty ? "" : String(value.prefix(3))))
                                .font(.system(size: 8, weight: isFree ? .bold : .regular))
                                .foregroundColor(isFree ? .white : .primary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 24)
                                .background(isFree ? Color.purple : Color(.systemBackground))
                                .overlay(
                                    Rectangle()
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
                                )
                        }
                    }
                }
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private func getColorForLetter(_ letter: String) -> Color {
        switch letter {
        case "B": return .blue
        case "I": return .red
        case "N": return .orange
        case "G": return .green
        case "O": return .purple
        default: return .gray
        }
    }
}

struct CardDetailView: View {
    let cardData: BingoCardData
    @ObservedObject var cardManager: CardManager
    @Environment(\.dismiss) var dismiss
    @StateObject private var bingoCard: BingoCard
    @State private var originalGrid: [[String]]
    @State private var showingShareSheet = false
    @State private var shareItems: [Any] = []
    @State private var playMode = false
    
    init(cardData: BingoCardData, cardManager: CardManager) {
        self.cardData = cardData
        self.cardManager = cardManager
        _bingoCard = StateObject(wrappedValue: BingoCard(from: cardData))
        _originalGrid = State(initialValue: cardData.grid)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text(playMode ? "Tap filled cells to mark them complete" : "")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top)
                    
                    BingoCardView(card: bingoCard, playMode: playMode)
                        .padding()
                    
                    VStack(spacing: 15) {
                        if playMode {
                            Button(action: {
                                if hasChanges {
                                    saveChanges()
                                }
                                withAnimation {
                                    playMode = false
                                }
                            }) {
                                HStack {
                                    Image(systemName: "pencil")
                                    Text("Edit Card")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.gradient)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .padding(.horizontal)
                        } else {
                            if hasChanges {
                                Button(action: {
                                    saveChanges()
                                }) {
                                    HStack {
                                        Image(systemName: "checkmark")
                                        Text("Save Changes")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue.gradient)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
                                .padding(.horizontal)
                            }
                            
                            Button(action: {
                                if bingoCard.isCardFilled() {
                                    withAnimation {
                                        playMode = true
                                    }
                                }
                            }) {
                                HStack {
                                    Image(systemName: "play.circle.fill")
                                    Text("Play Card")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(bingoCard.isCardFilled() ? Color.purple.gradient : Color.gray.gradient)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .padding(.horizontal)
                            .disabled(!bingoCard.isCardFilled())
                        }
                        
                        Button(action: {
                            shareBingoCard()
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share Card")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green.gradient)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        
                        Button(action: {
                            cardManager.deleteCard(cardData)
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Delete Card")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.gradient)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Card Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        if hasChanges {
                            saveChanges()
                        }
                        dismiss()
                    }
                }
            }
            .onDisappear {
                // Save any changes when leaving
                if hasChanges {
                    saveChanges()
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if !shareItems.isEmpty {
                    ShareSheet(items: shareItems, isPresented: $showingShareSheet)
                }
            }
        }
    }
    
    private var hasChanges: Bool {
        bingoCard.grid != originalGrid || !bingoCard.markedCells.isEmpty
    }
    
    private func saveChanges() {
        cardManager.updateCard(bingoCard, cardData: cardData)
        originalGrid = bingoCard.grid
        
        // Show feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    private func shareBingoCard() {
        // Create a shareable version of the card
        let shareView = BingoCardShareView(card: bingoCard)
        
        // Convert the view to an image
        let image = shareView.snapshot()
        
        // Create card data for deep linking (use current card data with updated grid if changed)
        let currentCardData = BingoCardData(
            id: bingoCard.id,
            grid: bingoCard.grid,
            dateCreated: cardData.dateCreated
        )
        
        // Encode card data to base64 string for URL
        guard let jsonData = try? JSONEncoder().encode(currentCardData),
              let base64String = jsonData.base64EncodedString().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            // Fallback to just sharing image if encoding fails
            shareItems = [image]
            showingShareSheet = true
            return
        }
        
        // Create deep link URL
        let deepLinkURL = URL(string: "bingocard://add?card=\(base64String)")!
        
        // Create share text with link
        let shareText = "Check out my Bingo Card! Tap the link to add it to your cards:\n\(deepLinkURL.absoluteString)\n\nOr get the app: https://apps.apple.com/app/bingo-card-maker"
        
        // Share both image and URL
        shareItems = [
            shareText,
            image,
            deepLinkURL
        ]
        
        // Show the share sheet
        showingShareSheet = true
    }
}

#Preview {
    MyCardsView(cardManager: CardManager())
}
