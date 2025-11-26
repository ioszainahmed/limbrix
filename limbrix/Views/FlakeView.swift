//
//  FlakeView.swift
//  limbrix
//
//  View for rendering individual flakes
//

import SwiftUI

struct FlakeView: View {
    let flake: Flake
    
    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(flake.color)
            .frame(width: flake.size, height: flake.size)
            .position(flake.position)
    }
}


