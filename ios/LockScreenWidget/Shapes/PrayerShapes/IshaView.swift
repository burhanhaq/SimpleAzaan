//
//  IshaView.swift
//  Runner
//
//  Created by Burhan Ul Haq on 10/6/22.
//

import SwiftUI
import WidgetKit
import Intents

struct IshaView: View {
    let lineWidth: CGFloat = 1
    
    var body: some View {
        ZStack{
            MoonShape()
            
            Rectangle()
                .frame(width: 4, height: lineWidth)
                .offset(CGSize(width: 0, height: -5))
            
            Rectangle()
                .frame(width: 3, height: lineWidth)
                .offset(CGSize(width: -2, height: -3))
            
            Rectangle()
                .frame(width: 2, height: lineWidth)
                .offset(CGSize(width: -8, height: -3))
            
            Rectangle()
                .frame(width: 3, height: lineWidth)
                .offset(CGSize(width: -12, height: -3))
            
            Rectangle()
                .frame(width: 3, height: lineWidth)
                .offset(CGSize(width: -10, height: 1))
            
            Rectangle()
                .frame(width: 3, height: lineWidth)
                .offset(CGSize(width: -7, height: 5))
            
            Rectangle()
                .frame(width: 4, height: lineWidth)
                .offset(CGSize(width: 8, height: 5))
        }
    }
}

struct IshaView_Previews: PreviewProvider {
    static var previews: some View {
        IshaView()
    }
}
