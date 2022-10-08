//
//  MaghribView.swift
//  Runner
//
//  Created by Burhan Ul Haq on 10/7/22.
//

import SwiftUI

struct MaghribView: View {
    var body: some View {
        ZStack {
            SunShape(filled: true)
                .frame(width: 17, height: 10, alignment: .top)
                .offset(CGSize(width: 0, height: 1))
                .clipped()
            EveningLines()
                .stroke(lineWidth: 1)
        }
        .frame(width: 15, height: 15)
        .offset(CGSize(width: 0, height: -4))
    }
}

struct EveningLines: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            // first line
            path.move(to: CGPoint(x: rect.midX - 15, y: rect.midY + 4))
            path.addLine(to: CGPoint(x: rect.midX + 15, y: rect.midY + 4))
            
            // second line
            path.move(to: CGPoint(x: rect.midX - 15, y: rect.midY + 6))
            path.addLine(to: CGPoint(x: rect.midX + 15, y: rect.midY + 6))
            
            // third set of lines
            path.move(to: CGPoint(x: rect.midX - 10, y: rect.midY + 8))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.midY + 8))
            
            path.move(to: CGPoint(x: rect.midX + 10, y: rect.midY + 9))
            path.addLine(to: CGPoint(x: rect.midX + 15, y: rect.midY + 9))
            
            // fourth set of lines
//            path.move(to: CGPoint(x: rect.midX - 18, y: rect.midY + 11))
//            path.addLine(to: CGPoint(x: rect.midX - 9, y: rect.midY + 11))
//
//            path.move(to: CGPoint(x: rect.midX, y: rect.midY + 11))
//            path.addLine(to: CGPoint(x: rect.midX + 6, y: rect.midY + 11))
            
        }
    }
}

struct MaghribView_Previews: PreviewProvider {
    static var previews: some View {
        MaghribView()
    }
}
