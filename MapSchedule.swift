//
//  MapSchedule.swift
//  MapTimer
//
//  Created by Jack Kroll on 3/10/25.
//

import Foundation
import SwiftUI

enum MapName {
    case KC, WE, OL, SP, BM, ED
}

struct Rotation {
    var maps: [MapName]
}

struct Map {
    var name: MapName
    var description: String?
    var availableAt: Date
    var availableTo: Date
    
    init(name: MapName, availableAt: Date, availableTo: Date) {
        self.name = name
        self.availableAt = availableAt
        self.availableTo = availableTo
    }
    
    init(name: MapName, availableAt: Double, availableTo: Double) {
        self.name = name
        self.availableAt = Date.init(timeIntervalSince1970: availableAt)
        self.availableTo = Date.init(timeIntervalSince1970: availableTo)
    }
    
    func mapName() -> String {
        switch(name) {
            case .KC: return "Kings Canyon"
            case .WE: return "Worlds Edge"
            case .OL: return "Olympus"
            case .SP: return "Storm Point"
            case .BM: return "Broken Moon"
            case .ED: return "E-District"
        }
        
    }
    
    func fontStyle() -> Font.Design {
        switch(name) {
        case .KC: return .default
        case .WE: return .default
        case .OL: return .serif
        case .SP: return .default
        case .BM: return .default
        case .ED: return .monospaced
        }
    }
    
    func mapColorBG() -> Color {
        switch(name) {
        case .KC: return .clear
        case .WE: return .clear
        case .OL: return .clear
        case .SP: return .clear
        case .BM: return .clear
        case .ED: return .clear
        }
    }
    
    func mapColorTX() -> Color {
        switch(name) {
        case .KC: return .red
        case .WE: return .green
        case .OL: return .blue
        case .SP: return .teal
        case .BM: return .purple
        case .ED: return .pink
        }
    }
    
    func isAvailable(at date: Date) -> Bool {
        return availableAt...availableTo ~= date
    }
    
    func timeUntilAvailable(at date: Date) -> TimeInterval {
        return date.distance(to: availableAt)
    }
    
    func timeUntilDone(at date: Date) -> TimeInterval {
        return date.distance(to: availableTo)
    }
    
    func percentComplete() -> Double {
        let complete = (availableTo.timeIntervalSince1970 - Date.now.timeIntervalSince1970)/(availableTo.timeIntervalSince1970-availableAt.timeIntervalSince1970)
        return complete.truncatingRemainder(dividingBy: 1)
    }
}


struct MapSchedule {
    let origin = Map(name: .KC, availableAt: 1741721400, availableTo: 1741726800)
    let rotation: [MapName] = [.BM ,.KC, .OL]
    let rotationInterval: Double = 5400
    
    func determineCurrentMap(at : Date) -> Map {
        let origin = origin
        let timeSinceOrigin : TimeInterval = at.timeIntervalSince1970 - origin.availableTo.timeIntervalSince1970
        let rawRotationIndex : Double = timeSinceOrigin / rotationInterval
        let rotationIndex : Int = Int(rawRotationIndex) + 1
        
        let availableAt = origin.availableAt.addingTimeInterval(Double(rotationIndex) * rotationInterval)
        let availableTo = availableAt.addingTimeInterval(rotationInterval)
        let map = Map(name: rotation[(rotationIndex) % rotation.count], availableAt: availableAt, availableTo: availableTo)
        return map
    }
    func upcomingMaps(at: Date, range: ClosedRange<Int>? = nil) -> [Map] {
        var maps: [Map] = []
        var chosenRange: ClosedRange<Int>
        if range == nil {
            chosenRange = 1...rotation.count
        }
        else {
            chosenRange = range!
        }
        for i in chosenRange {
            maps.append(determineCurrentMap(at: at + rotationInterval * Double(i)))
        }
        return maps
    }
}


