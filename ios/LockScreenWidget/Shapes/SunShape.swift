//
//  SunShape.swift
//  Runner
//
//  Created by Burhan Ul Haq on 10/7/22.
//

import SwiftUI
import Foundation


struct SunShape: View {
    var filled: Bool
    var body: some View {
        ZStack {
//            Arc()
//            Rectangle()
//                .foregroundColor(Color.blue)
            if (filled) {
                Sun()
            } else {
                Sun()
                    .stroke(lineWidth: 1)
            }
        }
        
            .frame(width: 15, height: 15)
    }
}

struct Sun: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            let rectCenter = CGPoint(x: rect.midX, y: rect.midY)
            let pi = Double.pi
            
            // Most outer broken circle
            let outerBrokenCircleRadius = rect.height / 2
//            path.move(to: CGPoint(x: rect.maxX, y: rect.midY))
//            path.addArc(
//                center: rectCenter,
//                radius: outerBrokenCircleRadius,
//                startAngle: Angle(radians: 0),
//                endAngle: Angle(radians: -pi/6),
//                clockwise: true)
//
//            path.move(to: CGPoint(x: rect.midX, y: 0))
//            path.addArc(
//                center: rectCenter,
//                radius: outerBrokenCircleRadius,
//                startAngle: Angle(radians: -pi/2),
//                endAngle: Angle(radians: -pi/1.3),
//                clockwise: true)
//
//            let xOffset = outerBrokenCircleRadius * sin(pi)
//            let yOffset = outerBrokenCircleRadius * cos(pi/2)
//            path.move(to: CGPoint(x: xOffset, y: rect.midY + yOffset))
//            path.addArc(
//                center: rectCenter,
//                radius: outerBrokenCircleRadius,
//                startAngle: Angle(radians: -pi),
//                endAngle: Angle(radians: pi/2),
//                clockwise: true)
            
            // Full outer circle
            let outerFullCircleRadius = outerBrokenCircleRadius * 1
            path.move(to: CGPoint(x: rect.maxX - (rect.midX - outerFullCircleRadius), y: rect.midY))
            path.addArc(
                center: rectCenter,
                radius: outerFullCircleRadius,
                startAngle: Angle(radians: 0),
                endAngle: Angle(radians: 2 * pi),
                clockwise: false)
            
            // Full inner circle
            let innerFullCircleRadius = outerFullCircleRadius
            path.move(to: CGPoint(x: rect.maxX - (rect.midX - innerFullCircleRadius), y: rect.midY))
            path.addArc(
                center: rectCenter,
                radius: innerFullCircleRadius,
                startAngle: Angle(radians: 0),
                endAngle: Angle(radians: 2 * pi),
                clockwise: false)
            
            // Most inner broken circle
            let innerBrokenCircleRadius = innerFullCircleRadius * 0.7
            path.move(to: CGPoint(x: rect.maxX - (rect.midX - innerBrokenCircleRadius), y: rect.midY))
            path.addArc(
                center: rectCenter,
                radius: innerBrokenCircleRadius,
                startAngle: Angle(radians: 0),
                endAngle: Angle(radians: -pi/2),
                clockwise: true)

            path.move(to: CGPoint(x: rect.midX - innerBrokenCircleRadius, y: rect.midY))
            path.addArc(
                center: rectCenter,
                radius: innerBrokenCircleRadius,
                startAngle: Angle(radians: pi),
                endAngle: Angle(radians: pi/2),
                clockwise: true)
        }
    }
}

struct SunShape_Previews: PreviewProvider {
    static var previews: some View {
        SunShape(filled: false)
    }
}
