//
//  LedButtonView.swift
//  LedController
//
//  Created by Miho Shimizu on 8/24/24.
//

import SwiftUI

struct LedButtonView: View {
    @Environment(LedViewModel.self) private var viewModel
    let led: Led

    var isSelected: Bool {
        guard let selectedLed = viewModel.selectedLed else { return false }
        return selectedLed == led
    }

    var body: some View {
        Button {
            viewModel.toggleLed(selectedLed: led)
        } label: {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 20.0)
                    .fill(led.ledColorTypeToColor().opacity(isSelected ? 0.4 : 1.0))
                    .shadow(radius: isSelected ? 0 : 10)

                Text(led.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .tint(.primary)
                    .padding()
            }
            .frame(height: 130)
        }
    }
}

#Preview {
    LedButtonView(led: Led(id: 0, name: "Preview", color: .ledColorRed))
}
