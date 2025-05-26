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
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
            case .KC:
                try container.encode("KC")
            case .WE:
                try container.encode("WE")
            case .OL:
                try container.encode("OL")
            case .SP:
                try container.encode("SP")
            case .BM:
                try container.encode("BM")
            case .ED:
                try container.encode("ED")
            }
    }
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
    
    func monogram() -> String {
        return name.rawValue.uppercased()
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
        return (availableAt...availableTo).contains(date)
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
    
    func rotationInterval() -> TimeInterval {
        return availableAt.distance(to: availableTo)
    }
    
    func headerText() -> String {
        //map rotation is short term, use time
        if (rotationInterval() < 43200) {
            return "\(mapName())" + (isAvailable(at: .now) ? "": " at ")
        }
        //map rotation is long term, use date
        else {
            return "\(mapName())" + (isAvailable(at: .now) ? " until ": " on ")
        }
    }
    
    func timerText() -> Text {
        //map rotation is short term, use time
        if (rotationInterval() < 43200) {
            return Text(isAvailable(at: .now) ? availableTo : availableAt, style: isAvailable(at: .now) ? .timer : .time)
        }
        //map rotation is long term, use date (usually ranked or season starts)
        else {
            return Text(isAvailable(at: .now) ? availableTo : availableAt, style: isAvailable(at: .now) ? .time : .date)
        }
    }
}
extension Map{
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(availableAt.timeIntervalSince1970, forKey: .availableAt)
        try container.encode(availableTo.timeIntervalSince1970, forKey: .availableTo)
        //try container.encode(availableAt, forKey: .availableAt)
        //try container.encode(availableTo, forKey: .availableTo)
        if (mixtapeMode != nil) {
            try container.encode(mixtapeMode, forKey: .mixtapeMode)
        }
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
                print("Fetching web schedule for ranked")
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
    
    func fetchHash() async -> String? {
        let url = URL(string: "https://map.jackk.dev/hash")!
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return String(data: data, encoding: .utf8)!
        }
        catch {
            return nil
        }
    }
    
    func fetchLTMS() async -> [MapSchedule] {
        do {
            let url = URL(string: "https://map.jackk.dev/ltm/schedule")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let response = try decoder.decode([MapSchedule].self, from: data)
            return response
        }
        catch {
            print(error)
            return []
        }
    }
    
    func shouldUpdate() async -> Bool {
        @AppStorage("hash") var hash : String = ""
        let websiteHash = await fetchHash()
        
        return websiteHash != nil && websiteHash! != hash
    }
    
    func fetchPlaylist(playlist: Playlist, forceUpdate: Bool = false) async throws -> MapSchedule {
        @AppStorage("accuracy") var accurate : Bool = false
        @AppStorage("hash") var hash : String = ""
        let key = playlist == .regular ? "pubs" : "ranked"
        let data = UserDefaults.standard.data(forKey: key)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        var schedule : MapSchedule? = nil
        
        let websiteHash = await fetchHash()
        
        if data != nil {
            //reading from user defaults
            schedule = try decoder.decode(MapSchedule.self, from: data!)
            //current data is accurate!
            if websiteHash != nil && websiteHash! == hash && !forceUpdate {
                accurate = true
                return schedule!
            }
        }
        //attempt web request if data is not accurate
        let response = try await fetchWebSchedule(playlist: playlist)
        if response != nil {
            //write updated web info!
            let encoder = JSONEncoder()
            let data = try encoder.encode(response)
            UserDefaults.standard.set(data, forKey: key)
            if websiteHash != nil {
                print("updated hash: \(websiteHash!)")
                hash = websiteHash!
            }
            else {
                print("error updating hash")
            }
            accurate = true
            return response!
        }
        //wanted to refresh data, but was unable, use possibly stale data
        if schedule != nil {
            accurate = false
            return schedule!
        }
        //all else, return hardcoded result :(
        accurate = false
        if (playlist == .regular) {
            return MapSchedule(origin: Map(name: .KC, availableAt: 1741721400, availableTo: 1741726800), rotation: [.BM,.KC,.OL])
        }
        else {
            return MapSchedule(origin: Map(name:.KC, availableAt: 1741716000, availableTo: 1741802400), rotation: [.OL, .SP,.KC])
        }
    }
}

struct MapSchedule : Codable {
    let origin : Map
    let rotation: [MapName]
    let takeoverName: String?
    let takeoverSystemImage: String?
    
    let rotationInterval: Double
    
    init(origin: Map, rotation: [MapName], takeoverName: String? = nil, takeoverSystemImage: String? = nil, rotationInterval: Double? = nil) {
        self.origin = origin
        self.rotation = rotation
        self.takeoverName = takeoverName
        self.takeoverSystemImage = takeoverSystemImage
        if rotationInterval ==  nil {
            self.rotationInterval = origin.availableTo.timeIntervalSince1970 - origin.availableAt.timeIntervalSince1970
        }
        else {
            self.rotationInterval = rotationInterval!
        }
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
