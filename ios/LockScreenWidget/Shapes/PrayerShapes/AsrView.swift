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
            SunShape(filled: true)
//                .offset(CGSize(width: 0, height: 9))
//                .clipped()
//                .frame(width: 10, height: 10)
                .scaleEffect(x: 0.7, y: 0.7, anchor: .center)
            AsrSunRays()
                .stroke(lineWidth: 1)
//                .offset(CGSize(width: 0, height: 9))
//            Rectangle()
//                .frame(width: 20, height: 15)
//                .foregroundColor(Color.white)
//                .offset(CGSize(width: 0, height: 15))
            
        }
            .offset(CGSize(width: 0, height: 3))
    }
}

struct AsrSunRays: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
//            let rectCenter = CGPoint(x: rect.midX, y: rect.midY)
//            path.move(to: rectCenter)
            let pi = Double.pi
            let longLine = 4.0
            let shortLine = 2.0
            let firstLayer = 8.0
            let secondLayer = firstLayer + longLine + 2
            
            // first short left line
//            path.move(to: CGPoint(x: rect.midX - firstLayer * sin(pi/8+pi/2), y: rect.midY - firstLayer * cos(pi/8+pi/2)))
//            path.addLine(to: CGPoint(x: rect.midX - (firstLayer + shortLine) * sin(pi/8+pi/2), y: rect.midY - (firstLayer + shortLine) * cos(pi/8+pi/2)))
            
            
            // left line - LONG
            path.move(to: CGPoint(x: rect.midX - firstLayer, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.midX - firstLayer - longLine, y: rect.midY))
            
            path.move(to: CGPoint(x: rect.midX - secondLayer, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.midX - secondLayer - shortLine, y: rect.midY))
            
            // second short left line
//            path.move(to: CGPoint(x: rect.midX - firstLayer * sin(pi/8+pi/4), y: rect.midY - firstLayer * cos(pi/8+pi/4)))
//            path.addLine(to: CGPoint(x: rect.midX - (firstLayer + longLine) * sin(pi/8+pi/4), y: rect.midY - (firstLayer + longLine) * cos(pi/8+pi/4)))
            
            // top left line - LONG
            path.move(to: CGPoint(x: rect.midX - firstLayer * sin(pi/4), y: rect.midY - firstLayer * cos(pi/4)))
            path.addLine(to: CGPoint(x: rect.midX - (firstLayer + longLine) * sin(pi/4), y: rect.midY - (firstLayer + longLine) * cos(pi/4)))
            
            path.move(to: CGPoint(x: rect.midX - secondLayer * sin(pi/4), y: rect.midY - secondLayer * cos(pi/4)))
            path.addLine(to: CGPoint(x: rect.midX - (secondLayer + shortLine) * sin(pi/4), y: rect.midY - (secondLayer + shortLine) * cos(pi/4)))
            
            // third short left line
//            path.move(to: CGPoint(x: rect.midX - firstLayer * sin(pi/8), y: rect.midY - firstLayer * cos(pi/8)))
//            path.addLine(to: CGPoint(x: rect.midX - (firstLayer + longLine) * sin(pi/8), y: rect.midY - (firstLayer + longLine) * cos(pi/8)))
            
            // top line - LONG
            path.move(to: CGPoint(x: rect.midX, y: rect.midY - firstLayer))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.midY - firstLayer - longLine))
            
            path.move(to: CGPoint(x: rect.midX, y: rect.midY - secondLayer))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.midY - secondLayer - shortLine))
            
            // first short right line
//            path.move(to: CGPoint(x: rect.midX - firstLayer * sin(-pi/8), y: rect.midY - firstLayer * cos(-pi/8)))
//            path.addLine(to: CGPoint(x: rect.midX - (firstLayer + longLine) * sin(-pi/8), y: rect.midY - (firstLayer + longLine) * cos(-pi/8)))
            
            // top right line - LONG
            path.move(to: CGPoint(x: rect.midX + firstLayer * sin(pi/4), y: rect.midY - firstLayer * cos(pi/4)))
            path.addLine(to: CGPoint(x: rect.midX + (firstLayer + longLine) * sin(pi/4), y: rect.midY - (firstLayer + longLine) * cos(pi/4)))
            
            path.move(to: CGPoint(x: rect.midX + secondLayer * sin(pi/4), y: rect.midY - secondLayer * cos(pi/4)))
            path.addLine(to: CGPoint(x: rect.midX + (secondLayer + shortLine) * sin(pi/4), y: rect.midY - (secondLayer + shortLine) * cos(pi/4)))
            
            // second short right line
//            path.move(to: CGPoint(x: rect.midX - firstLayer * sin(-pi/8-pi/4), y: rect.midY - firstLayer * cos(-pi/8-pi/4)))
//            path.addLine(to: CGPoint(x: rect.midX - (firstLayer + longLine) * sin(-pi/8-pi/4), y: rect.midY - (firstLayer + longLine) * cos(-pi/8-pi/4)))
            
            // right line - LONG
            path.move(to: CGPoint(x: rect.midX + firstLayer, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.midX + firstLayer + longLine, y: rect.midY))
            
            path.move(to: CGPoint(x: rect.midX + secondLayer, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.midX + secondLayer + shortLine, y: rect.midY))
            
            // third short right line
//            path.move(to: CGPoint(x: rect.midX - firstLayer * sin(-pi/8-pi/2), y: rect.midY - firstLayer * cos(-pi/8-pi/2)))
//            path.addLine(to: CGPoint(x: rect.midX - (firstLayer + shortLine) * sin(-pi/8-pi/2), y: rect.midY - (firstLayer + shortLine) * cos(-pi/8-pi/2)))
        }
    }
}


struct AsrView_Previews: PreviewProvider {
    static var previews: some View {
        AsrView()
    }
}
