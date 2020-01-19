//
//  Scorer.swift
//  Scorer
//
//  Created by Justin Renjilian on 1/18/20.
//  Copyright © 2020 Justin Renjilian. All rights reserved.
//

enum Bet: Int {
    case zero = 0
    case tichu = 100
    case grand = 200
}

enum Seat {
    case north, south, east, west
    
    var team: Team {
        get {
            switch self {
            case .north, .south:
                return .vertical
            case .east, .west:
                return .horizontal
            }
        }
    }
}

struct Player {
    let seat: Seat
    var bet: Bet = .zero
}

enum Team: String {
    case vertical
    case horizontal
}

enum First {
    case one(Seat, Int)
    case team(Seat)
    
    func getSeat() -> Seat {
        switch self {
        case let .one(seat, _):
            return seat
        case let .team(seat):
            return seat
        }
    }
}

struct HistoryItem {
    let verticalScore: Int
    let horizontalScore: Int
    
    static func + (left: HistoryItem, right: HistoryItem) -> HistoryItem {
        return HistoryItem(verticalScore: left.verticalScore + right.verticalScore, horizontalScore: left.horizontalScore + right.horizontalScore)
    }
}

struct PlayerBets {
    private var north: Bet = .zero
    private var south: Bet = .zero
    private var east: Bet = .zero
    private var west: Bet = .zero
    
    var betArray: [Player] {
        get {
            return [Player(seat: .north, bet: north), Player(seat: .south, bet: south), Player(seat: .east, bet: east), Player(seat: .west, bet: west)]
        }
    }
    
    func getBet(seat: Seat) -> Bet {
        switch seat {
        case .north:
            return north
        case .south:
            return south
        case .east:
            return east
        case .west:
            return west
        }
    }
    
    mutating func setBet(seat: Seat, bet: Bet) {
        switch seat {
        case .north:
            north = bet
        case .south:
            south = bet
        case .east:
            east = bet
        case .west:
            west = bet
        }
    }
}

struct GameState {
    private var history = [HistoryItem(verticalScore: 0, horizontalScore: 0)]
    var playerBets = PlayerBets()
    var turnScore = 50.0
    var currentScore: HistoryItem {
        get {
            return history.last!
        }
    }
    
    mutating func updateScore(score: HistoryItem) {
        history.append(score)
        reset()
    }
    
    mutating func undo() {
        let _ = history.popLast()
        reset()
    }
    
    private mutating func reset() {
        turnScore = 50
        playerBets = PlayerBets()
    }
}

func score(firstOut: First, playerBets: [Player], lastScore: HistoryItem) -> HistoryItem {
    var scores: Dictionary<Team, Int> = [.vertical: 0, .horizontal: 0]
    
    let firstOutSeat = firstOut.getSeat()
    
    for playerBet in playerBets {
        let multiplier = firstOutSeat == playerBet.seat ? 1 : -1
        scores[playerBet.seat.team]! += (multiplier * playerBet.bet.rawValue)
    }
    
    switch firstOut {
    case let .one(_, vertScore):
        scores[.vertical]! += vertScore
        scores[.horizontal]! += (100 - vertScore)
    case let .team(seat):
        let team = seat.team
        scores[team]! += 200
    }
    
    return lastScore + HistoryItem(verticalScore: scores[.vertical]!, horizontalScore: scores[.horizontal]!)
}
