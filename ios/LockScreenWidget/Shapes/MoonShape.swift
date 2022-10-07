//
//  MoonShape.swift
//  Runner
//
//  Created by Burhan Ul Haq on 10/6/22.
//

import SwiftUI
import Foundation

struct MoonShape: View {
    var body: some View {
        ZStack {
//            Arc()
//            Rectangle()
//                .foregroundColor(Color.blue)
            Arc()
                .stroke(lineWidth: 1)
        }
        
            .frame(width: 15, height: 15)
//        .scaleEffect(x: 0.2, y: 0.2)
    }
}

struct MoonShape_Previews: PreviewProvider {
    static var previews: some View {
        MoonShape()
    }
}

struct Arc: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            // Outer bigger arc
            path.move(to: CGPoint(x: rect.maxX, y: rect.midY))
            path.addArc(
                center: CGPoint(x: rect.midX, y: rect.midY),
                radius: rect.height / 2,
                startAngle: Angle(degrees: 0),
                endAngle: Angle(degrees: 270),
                clockwise: false)
            
            // Inner smaller arc
            let centerOffset: CGFloat = rect.maxX / 6
            path.addArc(
                center: CGPoint(x: rect.midX + centerOffset, y: rect.midY - centerOffset),
                radius: rect.height / 2.75,
                startAngle: Angle(degrees: 240),
                endAngle: Angle(degrees: 30),
                clockwise: true)
            
            // Inner most smallest arc
            let pi = Double.pi
            let r = rect.height / 2.6
            let firstAngle: Double = pi / 1.7
            let secondAngle: Double = pi / 1.1
            let xOffset: CGFloat = r * sin(CGFloat(firstAngle - pi/2))
            let yOffset: CGFloat = r * cos(CGFloat(firstAngle - pi/2))
            
//            let a = 5.19615
//            let b = 3.0
            path.move(to: CGPoint(x: rect.midX - xOffset, y: rect.midY + yOffset))
            path.addArc(
                center: CGPoint(x: rect.midX, y: rect.midY),
                radius: r,
                startAngle: Angle(radians: firstAngle),
                endAngle: Angle(radians: secondAngle),
                clockwise: false)
            
        }
    }
}

struct Arc3: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.maxX, y: rect.midY))
            path.addArc(
                center: CGPoint(x: rect.midX, y: rect.midY),
                radius: rect.height / 2,
                startAngle: Angle(degrees: 0),
                endAngle: Angle(degrees: 270),
                clockwise: false)

            path.addArc(
                center: CGPoint(x: rect.midX + rect.midX/2, y: rect.midY - rect.midY/2),
                radius: rect.height / 3,
                startAngle: Angle(degrees: 225),
                endAngle: Angle(degrees: 45),
                clockwise: true)
        }
    }
}
