//
//  ZuhrView.swift
//  Runner
//
//  Created by Burhan Ul Haq on 10/7/22.
//

import SwiftUI

struct ZuhrView: View {
    var body: some View {
        ZStack {
            SunShape()
            SunRays()
                .stroke(lineWidth: 1)
        }
    }
}

struct SunRays: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
//            let rectCenter = CGPoint(x: rect.midX, y: rect.midY)
//            path.move(to: rectCenter)
            let pi = Double.pi
            let outerBoundary = 10.0
            let longLine = 6.0
            let shortLine = 2.0
            
            // first short left line
            path.move(to: CGPoint(x: rect.midX - outerBoundary * sin(pi/8+pi/2), y: rect.midY - outerBoundary * cos(pi/8+pi/2)))
            path.addLine(to: CGPoint(x: rect.midX - (outerBoundary + shortLine) * sin(pi/8+pi/2), y: rect.midY - (outerBoundary + shortLine) * cos(pi/8+pi/2)))
            
            // left line - LONG
            path.move(to: CGPoint(x: rect.midX - outerBoundary, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.midX - outerBoundary - longLine, y: rect.midY))
            
            // second short left line
            path.move(to: CGPoint(x: rect.midX - outerBoundary * sin(pi/8+pi/4), y: rect.midY - outerBoundary * cos(pi/8+pi/4)))
            path.addLine(to: CGPoint(x: rect.midX - (outerBoundary + shortLine) * sin(pi/8+pi/4), y: rect.midY - (outerBoundary + shortLine) * cos(pi/8+pi/4)))
            
            // top left line - LONG
            path.move(to: CGPoint(x: rect.midX - outerBoundary * sin(pi/4), y: rect.midY - outerBoundary * cos(pi/4)))
            path.addLine(to: CGPoint(x: rect.midX - (outerBoundary + longLine) * sin(pi/4), y: rect.midY - (outerBoundary + longLine) * cos(pi/4)))
            
            // third short left line
            path.move(to: CGPoint(x: rect.midX - outerBoundary * sin(pi/8), y: rect.midY - outerBoundary * cos(pi/8)))
            path.addLine(to: CGPoint(x: rect.midX - (outerBoundary + shortLine) * sin(pi/8), y: rect.midY - (outerBoundary + shortLine) * cos(pi/8)))
            
            // top line - LONG
            path.move(to: CGPoint(x: rect.midX, y: rect.midY - outerBoundary))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.midY - outerBoundary - longLine))
            
            // first short right line
            path.move(to: CGPoint(x: rect.midX - outerBoundary * sin(-pi/8), y: rect.midY - outerBoundary * cos(-pi/8)))
            path.addLine(to: CGPoint(x: rect.midX - (outerBoundary + shortLine) * sin(-pi/8), y: rect.midY - (outerBoundary + shortLine) * cos(-pi/8)))
            
            // top right line - LONG
            path.move(to: CGPoint(x: rect.midX + outerBoundary * sin(pi/4), y: rect.midY - outerBoundary * cos(pi/4)))
            path.addLine(to: CGPoint(x: rect.midX + (outerBoundary + longLine) * sin(pi/4), y: rect.midY - (outerBoundary + longLine) * cos(pi/4)))
            
            // second short right line
            path.move(to: CGPoint(x: rect.midX - outerBoundary * sin(-pi/8-pi/4), y: rect.midY - outerBoundary * cos(-pi/8-pi/4)))
            path.addLine(to: CGPoint(x: rect.midX - (outerBoundary + shortLine) * sin(-pi/8-pi/4), y: rect.midY - (outerBoundary + shortLine) * cos(-pi/8-pi/4)))
            
            // right line - LONG
            path.move(to: CGPoint(x: rect.midX + outerBoundary, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.midX + outerBoundary + longLine, y: rect.midY))
            
            // third short right line
            path.move(to: CGPoint(x: rect.midX - outerBoundary * sin(-pi/8-pi/2), y: rect.midY - outerBoundary * cos(-pi/8-pi/2)))
            path.addLine(to: CGPoint(x: rect.midX - (outerBoundary + shortLine) * sin(-pi/8-pi/2), y: rect.midY - (outerBoundary + shortLine) * cos(-pi/8-pi/2)))
            
        }
    }
}

struct ZuhrView_Previews: PreviewProvider {
    static var previews: some View {
        ZuhrView()
    }
}
