//
//  BingoCardShareView.swift
//  Bingo
//
//  Created by Philip Nasralla on 1/16/26.
//

import SwiftUI

struct BingoCardShareView: View {
    let card: BingoCard
    
    var body: some View {
        VStack(spacing: 0) {
            // Header row with letters
            HStack(spacing: 0) {
                ForEach(card.letters, id: \.self) { letter in
                    Text(letter)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 60)
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
        .frame(width: 600, height: 720)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        .padding(30)
    }
    
    private func cellView(row: Int, column: Int) -> some View {
        let isFree = row == 2 && column == 2
        let value = card.getValue(row: row, column: column)
        
        return Text(isFree ? "FREE" : (value.isEmpty ? "" : value))
            .font(.system(size: isFree ? 20 : 22, weight: isFree ? .bold : .semibold, design: .rounded))
            .foregroundColor(isFree ? .white : .black)
            .multilineTextAlignment(.center)
            .lineLimit(3)
            .minimumScaleFactor(0.7)
            .frame(maxWidth: .infinity, minHeight: 120)
            .background(isFree ? Color.purple : Color.white)
            .overlay(
                Rectangle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1.5)
            )
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

#Preview {
    BingoCardShareView(card: BingoCard())
}
