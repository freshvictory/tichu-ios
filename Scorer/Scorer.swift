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
}

struct Player {
    let seat: Seat
    var bet: Bet = .zero
    var team: Team { seat.team }
}

enum Team: String {
    case vertical
    case horizontal
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

struct PlayerBets: Sequence {
    private var north: Bet = .zero
    private var south: Bet = .zero
    private var east: Bet = .zero
    private var west: Bet = .zero
    
    func makeIterator() -> PlayerBets.Iterator {
        return PlayerBets.Iterator(self)
    }
    
    func results(_ firstOut: First) -> (Int, Int) {
        var vertScore = 0
        var horzScore = 0
        
        for player in self {
            let multiplier = firstOut.seat == player.seat ? 1 : -1
            let score = multiplier * player.bet.rawValue
            
            switch player.team {
            case .vertical:
                vertScore += score
            case .horizontal:
                horzScore += score
            }
        }
        
        return (vertScore, horzScore)
    }
    
    func getTeamBets(_ team: Team) -> (Player, Player) {
        let players =  self.filter { p in
            p.team == team
        }

        return (players[0], players[1])
    }
    
    func getBet(_ seat: Seat) -> Bet {
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
    
    mutating func setBet(_ seat: Seat, bet: Bet) {
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

    struct Iterator: IteratorProtocol {
        typealias Element = Player
        let bets: PlayerBets
        var times = 0
        
        init(_ playerBets: PlayerBets) {
            bets = playerBets
        }
        
        mutating func next() -> Player? {
            times += 1
            if times == 1 {
                return Player(seat: .north, bet: bets.north)
            } else if times == 2 {
                return Player(seat: .south, bet: bets.south)
            } else if times == 3 {
                return Player(seat: .east, bet: bets.east)
            } else if times == 4 {
                return Player(seat: .west, bet: bets.west)
            } else {
                return nil
            }
        }
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
