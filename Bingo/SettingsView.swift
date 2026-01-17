//
//  SettingsView.swift
//  Bingo
//
//  Created by Philip Nasralla on 1/16/26.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("App Name")
                        Spacer()
                        Text("Bingo Card Maker")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("How to Use")) {
                    Text("• Tap any box on the card to add custom text")
                    Text("• You can add short phrases, multiple words, or single terms")
                    Text("• The center square is always FREE and cannot be edited")
                    Text("• Use 'Clear Card' to remove all text and start fresh")
                    Text("• Use 'Share Card' to save or share your custom bingo card")
                }
                
                Section(header: Text("Game Rules")) {
                    Text("Customize each square with your own text or phrases. Mark items as they're called. Win by completing a line horizontally, vertically, or diagonally!")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}