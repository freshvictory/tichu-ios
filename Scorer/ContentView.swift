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
    @State private var firstOut: First?
    
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
            HStack {
                Text("\(Int(state.turnScore))")
                .foregroundColor(Color.black)
                    .frame(minWidth: 40, alignment: .trailing)
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 2)
                Text("\(100 - Int(state.turnScore))")
                    .foregroundColor(Color.black)
                    .frame(minWidth: 40, alignment: .leading)
            }
            .padding(5)
            .background(Color.yellow)
            .cornerRadius(10)
            .roundedBorder(Color.gray, lineWidth: 3, cornerRadius: 10)
            .fixedSize()
            Slider(value: $state.turnScore, foregroundColor: .yellow, backgroundColor: .white, borderColor: .gray)
                .frame(width: 200, height: 50)
        }
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
                self.firstOut?.seat == player.seat
            }, set: {
                self.firstOut = $0 ? .one(player.seat, Int(self.state.turnScore)) : nil
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

    
    // MARK: Button actions.
    
    func userTappedScore() {
        if firstOut == nil {
            for player in state.playerBets {
                if player.bet == .zero {
                    firstOut = .one(player.seat, Int(state.turnScore))
                }
            }
        }
        
        if let first = firstOut {
            state.score(first)
            clear()
        }
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
        if let first = firstOut, first.seat == player.seat {
            firstOut = nil
        }
    }
    
    
    // MARK: Helpers.
    
    func clear() {
        firstOut = nil
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
