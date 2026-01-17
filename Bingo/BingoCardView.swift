//
//  BingoCardView.swift
//  Bingo
//
//  Created by Philip Nasralla on 1/16/26.
//

import SwiftUI

struct BingoCardView: View {
    @ObservedObject var card: BingoCard
    var playMode: Bool = false
    var onMarkToggle: ((Int, Int) -> Void)? = nil
    @State private var editingRow: Int? = nil
    @State private var editingColumn: Int? = nil
    @State private var editingText: String = ""
    @State private var showingEditSheet = false
    @State private var showingUnmarkConfirmation = false
    @State private var unmarkRow: Int? = nil
    @State private var unmarkColumn: Int? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            // Header row with letters
            HStack(spacing: 0) {
                ForEach(card.letters, id: \.self) { letter in
                    Text(letter)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(getColorForLetter(letter).gradient)
                }
            }
            .cornerRadius(12, corners: [.topLeft, .topRight])
            
            // Text grid
            ForEach(0..<5, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<5, id: \.self) { column in
                        cellView(row: row, column: column)
                    }
                }
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        .padding()
        .sheet(isPresented: $showingEditSheet) {
            EditCellView(
                text: $editingText,
                isPresented: $showingEditSheet,
                onSave: {
                    if let row = editingRow, let column = editingColumn {
                        card.setValue(row: row, column: column, value: editingText)
                    }
                    editingRow = nil
                    editingColumn = nil
                }
            )
        }
        .alert("Unmark Cell", isPresented: $showingUnmarkConfirmation) {
            Button("Cancel", role: .cancel) {
                unmarkRow = nil
                unmarkColumn = nil
            }
            Button("Unmark", role: .destructive) {
                if let row = unmarkRow, let column = unmarkColumn {
                    card.toggleMark(row: row, column: column)
                    onMarkToggle?(row, column)
                }
                unmarkRow = nil
                unmarkColumn = nil
            }
        } message: {
            Text("Are you sure you want to unmark this cell?")
        }
    }
    
    private func cellView(row: Int, column: Int) -> some View {
        let isFree = row == 2 && column == 2
        let value = card.getValue(row: row, column: column)
        let isEmpty = !isFree && value.isEmpty
        let isMarked = card.isMarked(row: row, column: column)
        let hasContent = !isFree && !value.isEmpty
        
        return Button(action: {
            if playMode && hasContent {
                // In play mode with content: mark/unmark
                if isMarked {
                    // Show confirmation for unmarking
                    unmarkRow = row
                    unmarkColumn = column
                    showingUnmarkConfirmation = true
                } else {
                    // Mark the cell
                    card.toggleMark(row: row, column: column)
                    onMarkToggle?(row, column)
                }
            } else if !isFree && !playMode {
                // In edit mode: open edit sheet
                editingRow = row
                editingColumn = column
                editingText = value
                showingEditSheet = true
            }
        }) {
            ZStack {
                Text(isEmpty ? "Tap to edit this" : (isFree ? "FREE" : value))
                    .font(.system(size: isFree ? 16 : (isEmpty ? 14 : 16), weight: isFree ? .bold : .semibold, design: .rounded))
                    .foregroundColor(isFree ? .white : (isEmpty ? .secondary : .primary))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.7)
                
                // Red dot overlay for marked cells
                if isMarked {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 20, height: 20)
                        .offset(x: 30, y: -30)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 70)
            .background(isFree ? Color.purple : Color(.systemBackground))
            .overlay(
                Rectangle()
                    .stroke(isEmpty ? Color.gray.opacity(0.4) : Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(playMode && isEmpty) // Disable empty cells in play mode
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

// Extension to create custom corner radius
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    BingoCardView(card: BingoCard())
        .padding()
}
