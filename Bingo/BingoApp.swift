//
//  BingoApp.swift
//  Bingo
//
//  Created by Philip Nasralla on 1/16/26.
//

import SwiftUI

@main
struct BingoApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .onOpenURL { url in
                    // Deep link handling is done in MainTabView
                    print("Received URL: \(url)")
                }
        }
    }
}
