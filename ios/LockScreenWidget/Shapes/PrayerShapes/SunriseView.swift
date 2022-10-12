//
//  SunriseView.swift
//  Runner
//
//  Created by Burhan Ul Haq on 10/7/22.
//

import SwiftUI

struct SunriseView: View {
    var body: some View {
        ZStack {
            SunShape(filled: true)
                .offset(CGSize(width: 0, height: 9))
                .clipped()
            SunriseSunRays()
                .stroke(lineWidth: 1)
                .offset(CGSize(width: 0, height: 9))
            
        }
    }
}

struct SunriseSunRays: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            let pi = Double.pi
            let longLine = 5.0
            let shortLine = 3.0
            let firstLayer = 10.0
            let secondLayer = firstLayer + longLine + 2
            
            // second short left line
//            path.move(to: CGPoint(x: rect.midX - outerBoundary * sin(pi/8+pi/4), y: rect.midY - outerBoundary * cos(pi/8+pi/4)))
//            path.addLine(to: CGPoint(x: rect.midX - (outerBoundary + shortLine) * sin(pi/8+pi/4), y: rect.midY - (outerBoundary + shortLine) * cos(pi/8+pi/4)))
            
            // left line - LONG
            path.move(to: CGPoint(x: rect.midX - firstLayer * sin(pi/4), y: rect.midY - firstLayer * cos(pi/4)))
            path.addLine(to: CGPoint(x: rect.midX - (firstLayer + longLine) * sin(pi/4), y: rect.midY - (firstLayer + longLine) * cos(pi/4)))
            
            path.move(to: CGPoint(x: rect.midX - secondLayer * sin(pi/4), y: rect.midY - secondLayer * cos(pi/4)))
            path.addLine(to: CGPoint(x: rect.midX - (secondLayer + shortLine) * sin(pi/4), y: rect.midY - (secondLayer + shortLine) * cos(pi/4)))
            
            // left line - SHORT
            path.move(to: CGPoint(x: rect.midX - firstLayer * sin(pi/8), y: rect.midY - firstLayer * cos(pi/8)))
            path.addLine(to: CGPoint(x: rect.midX - (firstLayer + longLine) * sin(pi/8), y: rect.midY - (firstLayer + longLine) * cos(pi/8)))
            
            // top line - LONG
            path.move(to: CGPoint(x: rect.midX, y: rect.midY - firstLayer))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.midY - firstLayer - longLine))
            
            path.move(to: CGPoint(x: rect.midX, y: rect.midY - secondLayer))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.midY - secondLayer - shortLine))
            
            // right line - SHORT
            path.move(to: CGPoint(x: rect.midX - firstLayer * sin(-pi/8), y: rect.midY - firstLayer * cos(-pi/8)))
            path.addLine(to: CGPoint(x: rect.midX - (firstLayer + longLine) * sin(-pi/8), y: rect.midY - (firstLayer + longLine) * cos(-pi/8)))
            
            // right line - LONG
            path.move(to: CGPoint(x: rect.midX + firstLayer * sin(pi/4), y: rect.midY - firstLayer * cos(pi/4)))
            path.addLine(to: CGPoint(x: rect.midX + (firstLayer + longLine) * sin(pi/4), y: rect.midY - (firstLayer + longLine) * cos(pi/4)))
            
            path.move(to: CGPoint(x: rect.midX + secondLayer * sin(pi/4), y: rect.midY - secondLayer * cos(pi/4)))
            path.addLine(to: CGPoint(x: rect.midX + (secondLayer + shortLine) * sin(pi/4), y: rect.midY - (secondLayer + shortLine) * cos(pi/4)))
            
            // second short right line
//            path.move(to: CGPoint(x: rect.midX - outerBoundary * sin(-pi/8-pi/4), y: rect.midY - outerBoundary * cos(-pi/8-pi/4)))
//            path.addLine(to: CGPoint(x: rect.midX - (outerBoundary + shortLine) * sin(-pi/8-pi/4), y: rect.midY - (outerBoundary + shortLine) * cos(-pi/8-pi/4)))
            
            
        }
    }
}

struct SunriseView_Previews: PreviewProvider {
    static var previews: some View {
        SunriseView()
    }
}
