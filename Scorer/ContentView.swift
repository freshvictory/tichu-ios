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
    @State private var presentAddBet: Team?
    @State private var firstOut: First = .one(.north, 50)
    
    var body: some View {
        ZStack {
            Color.white
                .edgesIgnoringSafeArea(.all)
            VStack {
                HStack(alignment: .center, spacing: 100) {
                    teamView(name: "Team 1", score: state.currentScore.verticalScore)
                    teamView(name: "Team 2", score: state.currentScore.horizontalScore)
                }
                scoreSliderView()
                    .padding()
                betsView()
                    .padding(30)
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
    }
    
    
    // MARK: View functions
    
    func teamView(name: String, score: Int) -> some View {
        VStack {
            Text(name)
                .foregroundColor(Color.black)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.yellow)
            Text("\(score)")
                .foregroundColor(Color.black)
                .fontWeight(.bold)
                .padding(5)
                .font(Font.system(size: 32))
        }
        .background(Color.white)
        .cornerRadius(10)
        .roundedBorder(Color.gray, lineWidth: 3, cornerRadius: 10)
    }
    
    func scoreSliderView() -> some View {
        VStack {
            turnScoresView()
            sliderView()
                .accentColor(.yellow)
                .frame(height: 50)
        }
    }
    
    func turnScoresView() -> some View {
        let score = self.firstOut.score
        
        return HStack {
                Text("\(score.0)")
                    .foregroundColor(Color.black)
                    .frame(minWidth: 40, alignment: .trailing)
                    .animation(nil)
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 2)
                Text("\(score.1)")
                    .foregroundColor(Color.black)
                    .frame(minWidth: 40, alignment: .leading)
                    .animation(nil)
            }
            .padding(5)
            .background(Color.yellow)
            .cornerRadius(10)
            .roundedBorder(Color.gray, lineWidth: 3, cornerRadius: 10)
            .fixedSize()
    }
    
    func betsView() -> some View {
        GeometryReader { geometry in
            HStack(alignment: .center, spacing: 20) {
                self.teamBets(.vertical)
                    .frame(minWidth: geometry.size.width / 2, alignment: .center)
                self.teamBets(.horizontal)
                    .frame(minWidth: geometry.size.width / 2, alignment: .center)
            }
        }.fixedSize(horizontal: false, vertical: true)
    }
    
    func teamBets(_ team: Team) -> some View {
        let (player1, player2) = state.playerBets.getTeamBets(team)

        if player1.bet == .zero && player2.bet == .zero {
            return AnyView(noBets(team))
        } else {
            return AnyView(someBets(player1: player1, player2: player2))
        }
    }
    
    func someBets(player1: Player, player2: Player) -> some View {
        VStack {
            viewBet(player1, closable: true)
        }
    }
    
    func viewBet(_ player: Player, closable: Bool) -> some View {
        let toggleBinding = Binding(
            get: {
                self.firstOut.seat == player.seat
            },
            set: {
                switch self.firstOut {
                case let .team(s):
                    if s.team == player.team {
                        self.firstOut = .team($0 ? player.seat : player.seat.opposite)
                    } else if $0 {
                        self.firstOut = .one(player.seat, 50)
                    }
                case let .one(_, score):
                    self.firstOut = .one($0 ? player.seat : self.state.playerBets.getAvailableFirstOut(), score)
                }
            }
        )
        
        return HStack(alignment: .center, spacing: 10) {
            Toggle(isOn: toggleBinding) {
                Text("\(player.bet.name)")
            }
            .animation(.easeInOut)
            .padding(15)
            .foregroundColor(Color.black)
            .background(Color.yellow)
            .cornerRadius(10)
            .contextMenu {
                Button(action: {
                    self.userTappedDeleteBet(player)
                }) {
                    Text("Delete")
                        .foregroundColor(.red)
                    Image(systemName: "trash")
                }
            }
        }
    }
    
    func noBets(_ team: Team) -> some View {
        Button(action: {
            self.userTappedAddBet(team)
        }) {
            Text("add bet")
                .italic()
                .foregroundColor(Color.black)
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
                .background(Color.yellow)
                .cornerRadius(10)
                .roundedBorder(Color.gray, lineWidth: 3, cornerRadius: 13)
        }.actionSheet(item: $presentAddBet) { t in
            ActionSheet(
                title: Text("Bet type"),
                buttons: [
                    .default(Text("Tichu")) {
                        self.userTappedTichu(t)
                    },
                    .default(Text("Grand Tichu")) {
                       self.userTappedGrandTichu(t)
                   },
                    .cancel()
                ]
            )
        }
    }
    
    func sliderView() -> some View {
        return ZStack {
            Rectangle()
                .foregroundColor(.white)
            HStack(alignment: .center, spacing: 5) {
                consecutiveVictory(.vertical)
                    .zIndex(2)
                Divider()
                sliderOrConsecutiveView(self.firstOut)
                Divider()
                consecutiveVictory(.horizontal)
            }.padding(.horizontal, 5)
        }
        .roundedBorder(Color.gray, lineWidth: 3, cornerRadius: 20)
    }
    
    func sliderOrConsecutiveView(_ firstOut: First) -> some View {
        return ZStack {
            scoreSliderView(seat: self.firstOut.seat, score: Double(self.firstOut.score.0))
                .scaleEffect(self.firstOut.isConsecutive ? 0 : 1)
                .animation(.spring())
                .padding(.horizontal, 20)
            ZStack {
                Rectangle()
                    .foregroundColor(.accentColor)
                    .cornerRadius(10)
                Text("Consecutive Victory")
                    .foregroundColor(.white)
            }
            .scaleEffect(self.firstOut.isConsecutive ? 1 : 0.1)
            .opacity(self.firstOut.isConsecutive ? 1 : 0)
            .animation(.spring())
        }
        .padding(.vertical, 10)
    }
    
    func scoreSliderView(seat: Seat, score: Double) -> some View {
        let haptic = UISelectionFeedbackGenerator()

        let minValue = -25.0
        let maxValue = 125.0
        let step = 5.0
        return ZStack {
            HStack(alignment: .center, spacing: 5) {
                ForEach(Array(stride(from: minValue, to: maxValue, by: step)), id: \.self) { v in
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 1)
                        .scaleEffect(CGFloat(self.circlePercentage(v, step: step, value: score)) * 6)
                        .animation(.easeOut)
                }
            }
            GeometryReader { geometry in
                ZStack(alignment: .center) {
                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(.accentColor)
                        .frame(width: 40, height: geometry.size.height)
                        .position(x: geometry.size.width * CGFloat(self.valuePercentage(self.firstOut.isConsecutive ? 50 : score, max: maxValue, min: minValue)), y: geometry.size.height / 2)
                        .animation(nil)
                }
                .gesture(DragGesture(minimumDistance: 0)
                    .onChanged({ value in
                        let percentage = min(max(0, Double(value.location.x / geometry.size.width)), 1)

                        let offsetValue = percentage * (maxValue - minValue) + minValue
                        let roundedValue = step * round(offsetValue / step)
                        if roundedValue != score {
                            haptic.selectionChanged()
                        }
                        self.firstOut = .one(seat, Int(roundedValue))
                    }))
            }
        }
    }
    
    func consecutiveVictory(_ team: Team) -> some View {
        let show: Bool
        switch self.firstOut {
        case let .team(s):
            show = team.seats.0 == s || team.seats.1 == s
        default:
            show = false
        }
        return Button(action: {
            self.userTappedConsecutiveVictory(team)
        }) {
            Image(systemName: "person.2.fill")
                .foregroundColor(show ? .white : .yellow)
                .padding(12)
                .background(show ? Color.accentColor : .white)
        }.clipShape(Circle())
        .padding(.vertical, 10)
    }
        
    func valuePercentage(_ value: Double, max: Double, min: Double) -> Double {
        (value - min) / (max - min)
    }
    
    func circlePercentage(_ circleValue: Double, step: Double, value: Double) -> Double {
        let limit = 10 * step
        let midPoint = value - step / 2
        
        if abs(midPoint - circleValue) > limit {
            return 0.2
        }
        
        let percentage = circleValue < midPoint
            ? (circleValue - (midPoint - limit)) / limit
            : (midPoint + limit - circleValue) / limit
        
        return max(percentage, 0.2)
    }

    
    // MARK: Button actions.
    
    func userTappedScore() {
        state.score(self.firstOut)
        clear()
    }
    
    func userTappedAddBet(_ team: Team) {
        presentAddBet = team
    }
    
    func userTappedTichu(_ team: Team) {
        let (player1, player2) = state.playerBets.getTeamBets(team)
        let seat = player1.bet == .zero ? player1.seat : player2.seat
        state.playerBets.setBet(seat, bet: .tichu)
    }
    
    func userTappedGrandTichu(_ team: Team) {
        let (player1, player2) = state.playerBets.getTeamBets(team)
        let seat = player1.bet == .zero ? player1.seat : player2.seat
        state.playerBets.setBet(seat, bet: .grand)        
    }
    
    func userTappedDeleteBet(_ player: Player) {
        state.playerBets.setBet(player.seat, bet: .zero)
        if self.firstOut.seat == player.seat {
            // TODO
//            firstOut = nil
        }
    }
    
    func userTappedConsecutiveVictory(_ team: Team) {
        switch self.firstOut {
        case let .team(s):
            if (s.team == team) {
                self.firstOut = .one(s, 50)
            } else {
                self.firstOut = .team(team == .horizontal ? .east : .north)
            }
        case let .one(s, _):
            if (s.team == team) {
                self.firstOut = .team(s)
            } else {
               self.firstOut = .team(team == .horizontal ? .east : .north)
           }
        }
    }
    
    
    // MARK: Helpers.
    
    func clear() {
//        firstOut = nil
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
