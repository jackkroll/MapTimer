//
//  MapSchedule.swift
//  MapTimer
//
//  Created by Jack Kroll on 3/10/25.
//

import Foundation
import SwiftUI

enum MapName : String, Codable {
    case KC, WE, OL, SP, BM, ED
}

struct Rotation : Codable{
    var maps: [MapName]
}

struct Map : Codable {
    var name: MapName
    var availableAt: Date
    var availableTo: Date
    var mixtapeMode: MixtapeMode?

    enum CodingKeys: String, CodingKey {
        case name
        case availableAt
        case availableTo
        case mixtapeMode
    }
    
    init(name: MapName, availableAt: Date, availableTo: Date, mixtapeMode: MixtapeMode? = nil) {
        self.name = name
        self.availableAt = availableAt
        self.availableTo = availableTo
        self.mixtapeMode = mixtapeMode
    }
    /*
    init(name: MapName, availableAt: String, availableTo: String, mixtapeMode: MixtapeMode? = nil) {
        self.name = name
        self.availableAt = ISO8601DateFormatter().date(from: availableAt) ?? .distantFuture
        self.availableTo = ISO8601DateFormatter().date(from: availableTo) ?? .distantFuture
        self.mixtapeMode = mixtapeMode
    }
     */
    
    init(name: MapName, availableAt: Double, availableTo: Double, mixtapeMode: MixtapeMode? = nil) {
        self.name = name
        self.availableAt = Date.init(timeIntervalSince1970: availableAt)
        self.availableTo = Date.init(timeIntervalSince1970: availableTo)
        self.mixtapeMode = mixtapeMode
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
/*
extension Map {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(MapName.self, forKey: .name)
        availableAt = try values.decode(Date.self, forKey: .availableAt)
        availableTo = try values.decode(Date.self, forKey: .availableTo)
        mixtapeMode = try values.decodeIfPresent(MixtapeMode.self, forKey: .mixtapeMode)
    }
}*/

enum MixtapeMode : Codable{
    case GunRun, TDM, Control
}

enum Playlist : Codable {
    case regular,ranked
}

//origin = Map(name: .KC, availableAt: 1741721400, availableTo: 1741726800)
//rotation = [.BM ,.KC, .OL]

struct CurrentMapRotation {
    
    func fetchWebSchedule(playlist: Playlist) async throws -> MapSchedule? {
        do {
            var url : URL
            if playlist == .regular {
                url = URL(string: "https://map.jackk.dev/pubs/schedule")!
            }
            else {
                url = URL(string: "https://map.jackk.dev/ranked/schedule")!
            }
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let response = try decoder.decode(MapSchedule.self, from: data)
            return response
        }
        catch {
            return nil
        }

    }
    
    func fetchPlaylist(playlist: Playlist) async throws -> MapSchedule {
        switch(playlist) {
        case .regular:
            let response = try await fetchWebSchedule(playlist: .regular)
            if response != nil {
                return response!
            }
            return MapSchedule(origin: Map(name: .KC, availableAt: 1741721400, availableTo: 1741726800), rotation: [.BM,.KC,.OL])
        case .ranked:
            let response = try await fetchWebSchedule(playlist: .ranked)
            if response != nil {
                return response!
            }
            return MapSchedule(origin: Map(name:.KC, availableAt: 1741716000, availableTo: 1741802400), rotation: [.OL, .SP,.KC])
        }
    }
    func fetchLTM() -> [MapSchedule] {
        return []
    }
}

struct MapSchedule : Codable {
    let origin : Map
    let rotation: [MapName]
    let takeoverName: String?
    
    let rotationInterval: Double
    
    init(origin: Map, rotation: [MapName], takeoverName: String? = nil) {
        self.origin = origin
        self.rotation = rotation
        self.takeoverName = takeoverName
        self.rotationInterval = origin.availableTo.timeIntervalSince1970 - origin.availableAt.timeIntervalSince1970
    }
    
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


struct GameRotation {
    
}
