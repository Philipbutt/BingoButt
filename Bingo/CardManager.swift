//
//  CardManager.swift
//  Bingo
//
//  Created by Philip Nasralla on 1/16/26.
//

import Foundation
import Combine

class CardManager: ObservableObject {
    @Published var savedCards: [BingoCardData] = []
    private let storageKey = "SavedBingoCards"
    private let maxCards = 6
    
    var canSaveMoreCards: Bool {
        savedCards.count < maxCards
    }
    
    var cardsRemaining: Int {
        max(0, maxCards - savedCards.count)
    }
    
    init() {
        loadCards()
        // Limit existing cards if user already has more than max
        if savedCards.count > maxCards {
            savedCards = Array(savedCards.prefix(maxCards))
            saveCards()
        }
    }
    
    func saveCard(_ card: BingoCard) -> Bool {
        guard canSaveMoreCards else {
            return false
        }
        
        let cardData = BingoCardData(
            id: UUID(), // Always create new ID for saving from Create tab
            grid: card.grid,
            dateCreated: Date(),
            markedCells: Array(card.markedCells.map { MarkedPosition(row: $0.row, column: $0.column) })
        )
        savedCards.append(cardData)
        saveCards()
        return true
    }
    
    func deleteCard(_ card: BingoCardData) {
        savedCards.removeAll { $0.id == card.id }
        saveCards()
    }
    
    func addCardFromData(_ cardData: BingoCardData) -> Bool {
        // Check if card already exists
        if savedCards.contains(where: { $0.id == cardData.id }) {
            return true // Already exists, no need to add
        }
        
        guard canSaveMoreCards else {
            return false
        }
        
        savedCards.append(cardData)
        saveCards()
        return true
    }
    
    func updateCard(_ card: BingoCard, cardData: BingoCardData) {
        if let index = savedCards.firstIndex(where: { $0.id == cardData.id }) {
            let updatedCardData = BingoCardData(
                id: cardData.id,
                grid: card.grid,
                dateCreated: cardData.dateCreated,
                markedCells: Array(card.markedCells.map { MarkedPosition(row: $0.row, column: $0.column) })
            )
            savedCards[index] = updatedCardData
            saveCards()
        }
    }
    
    private func saveCards() {
        if let encoded = try? JSONEncoder().encode(savedCards) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    private func loadCards() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([BingoCardData].self, from: data) {
            savedCards = decoded
        }
    }
}

struct BingoCardData: Identifiable, Codable {
    let id: UUID
    let grid: [[String]]
    let dateCreated: Date
    let markedCells: [MarkedPosition]?
    
    init(id: UUID, grid: [[String]], dateCreated: Date, markedCells: [MarkedPosition]? = nil) {
        self.id = id
        self.grid = grid
        self.dateCreated = dateCreated
        self.markedCells = markedCells
    }
}

struct MarkedPosition: Codable, Hashable {
    let row: Int
    let column: Int
}
