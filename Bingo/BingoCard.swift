//
//  BingoCard.swift
//  Bingo
//
//  Created by Philip Nasralla on 1/16/26.
//

import Foundation
import Combine
class BingoCard: Identifiable, ObservableObject {
    let id: UUID
    @Published var grid: [[String]]
    @Published var markedCells: Set<CellPosition>
    let letters = ["B", "I", "N", "G", "O"]
    
    struct CellPosition: Hashable {
        let row: Int
        let column: Int
    }
    
    init(id: UUID = UUID(), grid: [[String]]? = nil, markedCells: Set<CellPosition>? = nil) {
        self.id = id
        if let grid = grid {
            self.grid = grid
        } else {
            // Initialize 5x5 grid with empty strings
            // Center square (row 2, column 2) starts as "FREE"
            var rows: [[String]] = Array(repeating: Array(repeating: "", count: 5), count: 5)
            rows[2][2] = "FREE"
            self.grid = rows
        }
        self.markedCells = markedCells ?? []
    }
    
    init(from cardData: BingoCardData) {
        self.id = cardData.id
        self.grid = cardData.grid
        // Convert marked positions from cardData if available
        if let markedPositions = cardData.markedCells {
            self.markedCells = Set(markedPositions.map { CellPosition(row: $0.row, column: $0.column) })
        } else {
            self.markedCells = []
        }
    }
    
    func getValue(row: Int, column: Int) -> String {
        return grid[row][column]
    }
    
    func setValue(row: Int, column: Int, value: String) {
        // Don't allow editing the center "FREE" square
        if row == 2 && column == 2 {
            return
        }
        grid[row][column] = value
    }
    
    func clearCard() {
        grid = Array(repeating: Array(repeating: "", count: 5), count: 5)
        grid[2][2] = "FREE"
        markedCells.removeAll()
    }
    
    func isCardFilled() -> Bool {
        // Check if all non-FREE cells have text
        for row in 0..<5 {
            for column in 0..<5 {
                if row == 2 && column == 2 {
                    continue // Skip FREE cell
                }
                if grid[row][column].isEmpty {
                    return false
                }
            }
        }
        return true
    }
    
    func toggleMark(row: Int, column: Int) {
        let position = CellPosition(row: row, column: column)
        if markedCells.contains(position) {
            markedCells.remove(position)
        } else {
            markedCells.insert(position)
        }
    }
    
    func isMarked(row: Int, column: Int) -> Bool {
        let position = CellPosition(row: row, column: column)
        return markedCells.contains(position)
    }
}
