//
//  MosqueView.swift
//  Runner
//
//  Created by Burhan Ul Haq on 3/11/23.
//

import SwiftUI

struct MosqueView: View {
    var body: some View {
        ZStack {
            Circle()
                .frame(width: 20, height: 20)
        }
        .frame(width: 40, height: 40)
    }
}

struct Mosque: Shape {
    func path(in rect: CGRect) -> Path {
        let x = rect.maxX;
        let y = rect.maxY;
        return Path { path in
            // move to base
            path.move(to: CGPoint(x: x*0.5, y: y*0.8))
            // draw line left
            path.addLine(to: CGPoint(x: x*0.2, y: y*0.8))
            
            // first left curve
//            path.addQuadCurve(
//                to: CGPoint(x: x*0.48, y: y*0.3),
//                control: CGPoint(x: x*(-0.1), y: y*0.65))
            path.addCurve(
                to: CGPoint(x: x*0.48, y: y*0.3),
                control1: CGPoint(x: x*(-0.1), y: y*0.75),
                control2: CGPoint(x: x*(-0), y: y*0.3))
            
            // top left curve
//            path.addQuadCurve(
//                to: CGPoint(x: x*0.5, y: y*0.05),
//                control: CGPoint(x: x*0.5, y: y*0.4))
            
            path.addCurve(
                to: CGPoint(x: x*0.5, y: y*0.05),
                control1: CGPoint(x: x*(0.6), y: y*0.75),
                control2: CGPoint(x: x*(0.6), y: y*0.2))
            
            // TODO: DRAW THE SHAPES SEPARATELY. TRIANGLE ON TOP OF TRIANGLE
            
        }
    }
}

struct MosqueShape_Previews: PreviewProvider {
    static var previews: some View {
        MosqueView()
    }
}
