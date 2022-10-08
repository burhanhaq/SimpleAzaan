//
//  FajrView.swift
//  Runner
//
//  Created by Burhan Ul Haq on 10/7/22.
//

import SwiftUI

struct FajrView: View {
    var body: some View {
        ZStack {
            MoonShape(filled: false)
            StarShape()
                .offset(CGSize(width: 5, height: -5))
            MoonLines()
                .stroke()
        }
//        .frame(width: 15, height: 15)
//        .overlay (alignment: .topTrailing) {
//            StarShape()
//        }
        
    }
}

struct MoonLines: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            // first line
//            path.move(to: CGPoint(x: rect.midX - 9, y: rect.midY - 7))
//            path.addLine(to: CGPoint(x: rect.midX - 4, y: rect.midY - 7))
            
            // second line
            path.move(to: CGPoint(x: rect.midX - 12, y: rect.midY + 1))
            path.addLine(to: CGPoint(x: rect.midX - 8, y: rect.midY + 1))
            
            path.move(to: CGPoint(x: rect.midX + 4, y: rect.midY + 1))
            path.addLine(to: CGPoint(x: rect.midX + 12, y: rect.midY + 1))
            
            // third line
            path.move(to: CGPoint(x: rect.midX - 12, y: rect.midY + 6))
            path.addLine(to: CGPoint(x: rect.midX - 4, y: rect.midY + 6))
            
            path.move(to: CGPoint(x: rect.midX + 5, y: rect.midY + 6))
            path.addLine(to: CGPoint(x: rect.midX + 12, y: rect.midY + 6))
            
            
        }
    }
}

struct FajrView_Previews: PreviewProvider {
    static var previews: some View {
        FajrView()
    }
}
