//
//  AsrView.swift
//  Runner
//
//  Created by Burhan Ul Haq on 10/7/22.
//

import SwiftUI

struct AsrView: View {
    var body: some View {
        ZStack {
            SunShape(filled: false)
                .offset(CGSize(width: 0, height: 9))
                .clipped()
            SunRays2()
                .stroke(lineWidth: 1)
                .offset(CGSize(width: 0, height: 9))
//            Rectangle()
//                .frame(width: 20, height: 15)
//                .foregroundColor(Color.white)
//                .offset(CGSize(width: 0, height: 15))
            
        }
    }
}

struct SunRays2: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            let pi = Double.pi
            let longLine = 5.0
            let shortLine = 3.0
            let outerBoundary = 10.0
            let extendedBoundary = outerBoundary + longLine + 2
            
            // second short left line
//            path.move(to: CGPoint(x: rect.midX - outerBoundary * sin(pi/8+pi/4), y: rect.midY - outerBoundary * cos(pi/8+pi/4)))
//            path.addLine(to: CGPoint(x: rect.midX - (outerBoundary + shortLine) * sin(pi/8+pi/4), y: rect.midY - (outerBoundary + shortLine) * cos(pi/8+pi/4)))
            
            // left line - LONG
            path.move(to: CGPoint(x: rect.midX - outerBoundary * sin(pi/4), y: rect.midY - outerBoundary * cos(pi/4)))
            path.addLine(to: CGPoint(x: rect.midX - (outerBoundary + longLine) * sin(pi/4), y: rect.midY - (outerBoundary + longLine) * cos(pi/4)))
            
            path.move(to: CGPoint(x: rect.midX - extendedBoundary * sin(pi/4), y: rect.midY - extendedBoundary * cos(pi/4)))
            path.addLine(to: CGPoint(x: rect.midX - (extendedBoundary + shortLine) * sin(pi/4), y: rect.midY - (extendedBoundary + shortLine) * cos(pi/4)))
            
            // left line - SHORT
            path.move(to: CGPoint(x: rect.midX - outerBoundary * sin(pi/8), y: rect.midY - outerBoundary * cos(pi/8)))
            path.addLine(to: CGPoint(x: rect.midX - (outerBoundary + longLine) * sin(pi/8), y: rect.midY - (outerBoundary + longLine) * cos(pi/8)))
            
            // top line - LONG
            path.move(to: CGPoint(x: rect.midX, y: rect.midY - outerBoundary))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.midY - outerBoundary - longLine))
            
            path.move(to: CGPoint(x: rect.midX, y: rect.midY - extendedBoundary))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.midY - extendedBoundary - shortLine))
            
            // right line - SHORT
            path.move(to: CGPoint(x: rect.midX - outerBoundary * sin(-pi/8), y: rect.midY - outerBoundary * cos(-pi/8)))
            path.addLine(to: CGPoint(x: rect.midX - (outerBoundary + longLine) * sin(-pi/8), y: rect.midY - (outerBoundary + longLine) * cos(-pi/8)))
            
            // right line - LONG
            path.move(to: CGPoint(x: rect.midX + outerBoundary * sin(pi/4), y: rect.midY - outerBoundary * cos(pi/4)))
            path.addLine(to: CGPoint(x: rect.midX + (outerBoundary + longLine) * sin(pi/4), y: rect.midY - (outerBoundary + longLine) * cos(pi/4)))
            
            path.move(to: CGPoint(x: rect.midX + extendedBoundary * sin(pi/4), y: rect.midY - extendedBoundary * cos(pi/4)))
            path.addLine(to: CGPoint(x: rect.midX + (extendedBoundary + shortLine) * sin(pi/4), y: rect.midY - (extendedBoundary + shortLine) * cos(pi/4)))
            
            // second short right line
//            path.move(to: CGPoint(x: rect.midX - outerBoundary * sin(-pi/8-pi/4), y: rect.midY - outerBoundary * cos(-pi/8-pi/4)))
//            path.addLine(to: CGPoint(x: rect.midX - (outerBoundary + shortLine) * sin(-pi/8-pi/4), y: rect.midY - (outerBoundary + shortLine) * cos(-pi/8-pi/4)))
            
            
        }
    }
}

struct AsrView_Previews: PreviewProvider {
    static var previews: some View {
        AsrView()
    }
}
