//
//  ContentView.swift
//  LedController
//
//  Created by Miho Shimizu on 8/24/24.
//

import SwiftUI

struct ContentView: View {
    @State var viewModel = LedViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                LazyVGrid(columns: [GridItem(), GridItem()]) {
                    ForEach(viewModel.leds) { led in
                        LedButtonView(led: led)
                            .environment(viewModel)
                            .padding(3)
                    }
                }
            }
            .padding()
            
            Spacer()
        }
        .navigationTitle("LED Controller")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    
                } label: {
                     Image(systemName: "plus")
                        .tint(.primary)
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    
                } label: {
                     Image(systemName: "gearshape")
                        .tint(.primary)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ContentView()
    }
}
