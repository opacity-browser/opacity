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
    
    
//    // 상단 왼쪽 둥근 모서리
//    path.addArc(center: CGPoint(x: cornerRadius, y: cornerRadius), radius: cornerRadius,
//                startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
//
//    // 상단 오른쪽 둥근 모서리
//    path.addArc(center: CGPoint(x: rect.width - cornerRadius, y: cornerRadius), radius: cornerRadius,
//                startAngle: Angle(degrees: 270), endAngle: Angle(degrees: 0), clockwise: false)
//    
//    // 나머지 직선 부분
//    path.addLine(to: CGPoint(x: rect.width, y: rect.height))
//    path.addLine(to: CGPoint(x: 0, y: rect.height))
//    path.closeSubpath()
    
    ////
    
//    // 상단 왼쪽 모서리
//    path.move(to: CGPoint(x: rect.minX, y: rect.minY + rect.height / 2))
//    path.addArc(center: CGPoint(x: rect.minX + rect.height / 2, y: rect.minY + rect.height / 2),
//                radius: rect.height / 2,
//                startAngle: Angle(degrees:180),
//                endAngle: Angle(degrees: 270),
//                clockwise: false)
//    // 상단 가장자리
//    path.addLine(to: CGPoint(x: rect.maxX - rect.height / 2, y: rect.minY))
//    
//    // 상단 오른쪽 모서리
//    path.addArc(center: CGPoint(x: rect.maxX - rect.height / 2, y: rect.minY + rect.height / 2),
//                radius: rect.height / 2,
//                startAngle: Angle(degrees: 270),
//                endAngle: Angle(degrees: 0),
//                clockwise: false)
//    
//    // 오른쪽 가장자리
//    path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - rect.height / 2))
//    
//    // 아래쪽 오른쪽 모서리
//    path.addArc(center: CGPoint(x: rect.maxX - rect.height / 2, y: rect.maxY - rect.height / 2),
//                radius: rect.height / 2,
//                startAngle: Angle(degrees: 0),
//                endAngle: Angle(degrees: 90),
//                clockwise: true)
//    
//    // 아래쪽 가장자리
//    path.addLine(to: CGPoint(x: rect.minX + rect.height / 2, y: rect.maxY))
//    
//    // 아래쪽 왼쪽 모서리
//    path.addArc(center: CGPoint(x: rect.minX + rect.height / 2, y: rect.maxY - rect.height / 2),
//                radius: rect.height / 2,
//                startAngle: Angle(degrees: 90),
//                endAngle: Angle(degrees: 180),
//                clockwise: true)
    
    // 완성된 패스를 반환
    return path
  }
}
