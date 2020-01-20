//
//  Slider.swift
//  Scorer
//
//  Created by Justin Renjilian on 1/18/20.
//  Copyright © 2020 Justin Renjilian. All rights reserved.
//
//  Inspired by https://stackoverflow.com/a/58288003
//

import SwiftUI

struct Slider: View {
    @Binding var value: Double

    var minValue = -25.0
    var maxValue = 125.0
    var step = 5.0

    var foregroundColor = Color.accentColor
    var backgroundColor = Color.white
    var borderColor = Color.gray
    
    var body: some View {
        let haptic = UISelectionFeedbackGenerator()
        return ZStack {
            Rectangle()
                .foregroundColor(self.backgroundColor)
            ZStack {
                HStack {
                    ForEach(Array(stride(from: self.minValue, to: self.maxValue, by: self.step)), id: \.self) { v in
                        Circle()
                            .fill(self.borderColor)
                            .frame(minWidth: 2)
                            .scaleEffect(CGFloat(self.circlePercentage(v)) * 3)
                            .animation(.easeOut)
                    }
                }
                GeometryReader { geometry in
                    ZStack(alignment: .center) {
                        Rectangle()
                            .fill(self.backgroundColor.opacity(0.1))
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(self.foregroundColor)
                            .frame(width: 40, height: geometry.size.height)
                            .position(x: self.getThumbXPosition(geometry.size.width), y: geometry.size.height / 2)
                    }
                    .gesture(DragGesture(minimumDistance: 0)
                        .onChanged({ value in
                            let percentage = min(max(0, Double(value.location.x / geometry.size.width)), 1)

                            let offsetValue = percentage * (self.maxValue - self.minValue) + self.minValue
                            let roundedValue = self.step * round(offsetValue / self.step)
                            if roundedValue != self.value {
                                haptic.selectionChanged()
                            }
                            self.value = roundedValue
                        }))
                }
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 10)
        }
        .roundedBorder(borderColor, lineWidth: 3, cornerRadius: 20)
        .frame(maxHeight: 50)
    }
    
    func getThumbXPosition(_ trackWidth: CGFloat) -> CGFloat {
        trackWidth * CGFloat(self.valuePercentage(self.value))
    }
    
    func valuePercentage(_ value: Double) -> Double {
        (value - self.minValue) / (self.maxValue - self.minValue)
    }
    
    func circlePercentage(_ circleValue: Double) -> Double {
        let limit = 10 * self.step
        let midPoint = self.value - self.step / 2
        
        if abs(midPoint - circleValue) > limit {
            return 0.2
        }
        
        let percentage = circleValue < midPoint
            ? (circleValue - (midPoint - limit)) / limit
            : (midPoint + limit - circleValue) / limit
        
        return max(percentage, 0.2)
    }
}

struct Slider_Previews: PreviewProvider {
    
    struct SliderBindingView: View {
        @State var value = 50.0
        
        var body: some View {
            Slider(value: $value)
//                .padding(.horizontal, 40)
        }
    }
    
    static var previews: some View {
        SliderBindingView()
            .previewLayout(.fixed(width: 500, height: 500))
    }
}
