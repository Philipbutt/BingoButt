//
//  ShareSheet.swift
//  Bingo
//
//  Created by Philip Nasralla on 1/16/26.
//

import SwiftUI
import UIKit

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        // For iPad support
        if let popover = controller.popoverPresentationController {
            popover.sourceView = UIView()
            popover.permittedArrowDirections = .any
        }
        
        controller.completionWithItemsHandler = { _, _, _, _ in
            isPresented = false
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

extension View {
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view!
        
        let targetSize = CGSize(width: 600, height: 720)
        view.bounds = CGRect(origin: .zero, size: targetSize)
        view.backgroundColor = .white
        
        // Ensure the view is laid out properly
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        
        return renderer.image { context in
            view.layer.render(in: context.cgContext)
        }
    }
}
