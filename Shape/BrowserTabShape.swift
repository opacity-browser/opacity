//
//  BrowserTabShape.swift
//  Opacity
//
//  Created by Falsy on 1/16/24.
//

import SwiftUI

struct BrowserTabShape: Shape {
  var cornerRadius: CGFloat
  
  func path(in rect: CGRect) -> Path {
    let bottomDecoRadius: Double = 6
    var path = Path()
    
    // 왼쪽 아래 데코
    path.addArc(center: CGPoint(x: rect.minX, y: rect.maxY - bottomDecoRadius),
                radius: bottomDecoRadius,
                startAngle: Angle(degrees: 0),
                endAngle: Angle(degrees: 90),
                clockwise: false)
    
    // 하상단 가로선
    path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
    
    // 오른쪽 아래 데코
    path.addArc(center: CGPoint(x: rect.maxX, y: rect.maxY - bottomDecoRadius),
                radius: bottomDecoRadius,
                startAngle: Angle(degrees: 90),
                endAngle: Angle(degrees: 180),
                clockwise: false)
    
    
    // 오른쪽 세로선
    path.addLine(to: CGPoint(x: rect.maxX - bottomDecoRadius, y: rect.minY + cornerRadius))
    
    // 오른쪽 상단 둥근 모서리
    path.addArc(center: CGPoint(x: rect.maxX - bottomDecoRadius - cornerRadius, y: rect.minY + cornerRadius),
                radius: cornerRadius,
                startAngle: Angle(degrees: 0),
                endAngle: Angle(degrees: 270),
                clockwise: true)
    
    
    // 상단 가로선
    path.addLine(to: CGPoint(x: rect.minX + bottomDecoRadius, y: rect.minY))

    // 왼쪽 상단 둥근 모서리
    path.addArc(center: CGPoint(x: rect.minX + bottomDecoRadius + cornerRadius, y: rect.minY + cornerRadius),
                radius: cornerRadius,
                startAngle: Angle(degrees: 270),
                endAngle: Angle(degrees: 180),
                clockwise: true)

    // 왼쪽 세로선
    path.addLine(to: CGPoint(x: bottomDecoRadius, y: rect.maxY - bottomDecoRadius))
    
    return path
  }
}
