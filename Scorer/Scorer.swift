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
    
    var name: String {
        switch self {
        case .zero:
            return "No bet"
        case .tichu:
            return "Tichu"
        case .grand:
            return "Grand"
        }
    }
}

enum Seat {
    case north, south, east, west
    
    var team: Team {
        switch self {
        case .north, .south:
            return .vertical
        case .east, .west:
            return .horizontal
        }
    }
    
    var opposite: Seat {
        switch self {
        case .north:
            return .south
        case .south:
            return .north
        case .east:
            return .west
        case .west:
            return .east
        }
    }
}

struct Player {
    let seat: Seat
    var bet: Bet = .zero
    var team: Team { seat.team }
}

enum Team: String {
    case vertical
    case horizontal
    
    var seats: (Seat, Seat) {
        switch self {
        case .vertical:
            return (.north, .south)
        case .horizontal:
            return (.east, .west)
        }
    }
    
    var opposite: Team {
        switch self {
        case .vertical:
            return .horizontal
        case .horizontal:
            return .vertical
        }
    }
}

extension Team: Identifiable {
    var id: String { rawValue }
}

enum First {
    case one(Seat, Int)
    case team(Seat)
    
    var seat: Seat {
        switch self {
        case let .one(seat, _):
            return seat
        case let .team(seat):
            return seat
        }
    }
    
    var score: (Int, Int) {
        switch self {
        case let .one(_, i):
            return (i, 100 - i)
        case let .team(seat):
            switch seat.team {
            case .vertical:
                return (200, 0)
            case .horizontal:
                return (0, 200)
            }
        }
    }
    
    var isConsecutive: Bool {
        switch self {
        case .one(_, _):
            return false
        case .team(_):
            return true
        }
    }
}

struct HistoryItem {
    let verticalScore: Int
    let horizontalScore: Int
    
    static let zero = HistoryItem(verticalScore: 0, horizontalScore: 0)
    
    private init(verticalScore: Int, horizontalScore: Int) {
        self.verticalScore = verticalScore
        self.horizontalScore = horizontalScore
    }

    init(firstOut: First, playerBets: PlayerBets, previous: HistoryItem = .zero) {
        let (vertTurnScore, horzTurnScore) = firstOut.score
        
        let (vertBetResults, horzBetResuts) = playerBets.results(firstOut)
        
        self.verticalScore = previous.verticalScore + vertTurnScore + vertBetResults
        self.horizontalScore = previous.horizontalScore + horzTurnScore + horzBetResuts
    }
}

struct PlayerBets {
    private var bets: Dictionary<Seat, Bet> = [:]
    
    func results(_ firstOut: First) -> (Int, Int) {
        var vertScore = 0
        var horzScore = 0
        
        for (seat, bet) in self.bets {
            let multiplier = firstOut.seat == seat ? 1 : -1
            let score = multiplier * bet.rawValue
            
            switch seat.team {
            case .vertical:
                vertScore += score
            case .horizontal:
                horzScore += score
            }
        }
        
        return (vertScore, horzScore)
    }
    
    func getAvailableFirstOut() -> Seat {
        for seat: Seat in [.north, .east, .south, .west] {
            if self.bets[seat] == nil {
                return seat
            }
        }
        
        return .west
    }
    
    func getTeamBets(_ team: Team) -> (Player, Player) {
        (Player(seat: team.seats.0, bet: getBet(team.seats.0)),
         Player(seat: team.seats.1, bet: getBet(team.seats.1)))
    }
    
    func getBet(_ seat: Seat) -> Bet {
        return self.bets[seat] ?? .zero
    }
    
    mutating func setBet(_ seat: Seat, bet: Bet) {
        self.bets[seat] = bet
    }
}

struct GameState {
    private var history = [HistoryItem.zero]
    var playerBets = PlayerBets()
    var turnScore = 50.0
    var currentScore: HistoryItem {
        get {
            return history.last!
        }
    }
    
    mutating func score(_ firstOut: First) {
        history.append(HistoryItem(firstOut: firstOut, playerBets: playerBets, previous: history.last!))
        clear()
    }
    
    mutating func undo() {
        let _ = history.popLast()
        clear()
    }
    
    private mutating func clear() {
        turnScore = 50
        playerBets = PlayerBets()
    }
}
