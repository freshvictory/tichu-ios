//
//  ContentView.swift
//  Scorer
//
//  Created by Justin Renjilian on 1/18/20.
//  Copyright © 2020 Justin Renjilian. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var state = GameState()
    
    var body: some View {
        VStack {
            HStack(alignment: .center, spacing: 100) {
                teamView(name: "Team 1", score: state.currentScore.verticalScore)
                teamView(name: "Team 2", score: state.currentScore.horizontalScore)
            }
            scoreSliderView()
                .padding()
            Button(action: userTappedScore) {
                Text("Score")
                    .foregroundColor(Color.black)
                    .frame(maxWidth: 200, maxHeight: 50)
                    .background(Color.yellow)
                    .cornerRadius(10)
                    .padding()
            }
            Spacer()
        }
        .padding()
    }
    
    func userTappedScore() {
        state.updateScore(score: score(firstOut: .one(.north, Int(state.turnScore)), playerBets: state.playerBets.betArray, lastScore: state.currentScore))
    }
    
    func scoreSliderView() -> some View {
        VStack {
            HStack {
                Text("\(Int(state.turnScore))")
                    .frame(minWidth: 40, alignment: .trailing)
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 2)
                Text("\(100 - Int(state.turnScore))")
                    .frame(minWidth: 40, alignment: .leading)
            }
            .padding(5)
            .background(Color.yellow)
            .cornerRadius(10)
            .roundedBorder(Color.gray, lineWidth: 3, cornerRadius: 10)
            .fixedSize()
            Slider(value: $state.turnScore, minValue: -25, maxValue: 125, step: 5, foregroundColor: .yellow, backgroundColor: .gray)
                .frame(width: 300, height: 50)
        }
    }
    
    func teamView(name: String, score: Int) -> some View {
        VStack {
            Text(name)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.yellow)
            Text("\(score)")
                .fontWeight(.bold)
                .padding(5)
                .font(Font.system(size: 32))
        }
        .background(Color.white)
        .roundedBorder(Color.gray, lineWidth: 3, cornerRadius: 10)
    }
}

extension View {
    func roundedBorder<S>(_ content: S, lineWidth: CGFloat = 1, cornerRadius: CGFloat
     = 0) -> some View where S : ShapeStyle {
        return overlay(RoundedRectangle(cornerRadius: cornerRadius).stroke(content, lineWidth: lineWidth))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
