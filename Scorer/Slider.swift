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
    var minValue = 0.0
    var maxValue = 100.0
    var step = 1.0
    var foregroundColor = Color.accentColor
    var backgroundColor = Color.gray
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(self.backgroundColor)
            GeometryReader { geometry in
                ZStack(alignment: .center) {
                    Rectangle()
                        .foregroundColor(self.backgroundColor)
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(self.foregroundColor)
                        .frame(width: 40, height: geometry.size.height)
                        .position(x: geometry.size.width * CGFloat((self.value - self.minValue) / (self.maxValue - self.minValue)), y: geometry.size.height / 2)
                }
                .gesture(DragGesture(minimumDistance: 0)
                    .onChanged({ value in
                        let percentage = min(max(0, Double(value.location.x / geometry.size.width)), 1)

                        let offsetValue = percentage * (self.maxValue - self.minValue) + self.minValue
                        let roundedValue = self.step * round(offsetValue / self.step)
                        if roundedValue != self.value {
                            // TODO: haptics
                        }
                        self.value = roundedValue
                    }))
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 10)
        }
        .cornerRadius(20)
        .frame(maxHeight: 50)
    }
}

struct Slider_Previews: PreviewProvider {
    static var previews: some View {
        Slider(value: Binding.constant(50), minValue: -25, maxValue: 125, step: 5)
            .padding(.horizontal, 40)
    }
}
