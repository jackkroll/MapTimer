//
//  NotificationViews.swift
//  MapTimer
//
//  Created by Jack Kroll on 4/9/25.
//

import Foundation
import SwiftUI

struct NotificationBell : View {
    @State var map : Map
    @Environment(\.colorScheme) var colorScheme
    @State var toggleSheet = false
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Image(systemName: "bell.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                    .foregroundStyle(.background.tertiary)
                    .onTapGesture {
                        toggleSheet = true
                    }
            }
            Spacer()
        }
        .padding()
        .sheet(isPresented: $toggleSheet) {
            NotificationSheet(map: map)
                .presentationDetents([.fraction(0.4)])
        }
    }
}

struct NotificationSheet : View {
    @Environment(\.dismiss) private var dismiss
    @State var map : Map
    @State var notifyMeBefore : Bool = false
    @State var notifyBeforeTime : Double = 10
    @State var notifyMeUponChange : Bool = true
    var body: some View {
        ZStack {
            VStack (spacing: 20){
                Text("One Time Notification")
                    .fontWeight(.semibold)
                    .font(.largeTitle)
                    .padding(.top, 20)
                Toggle(notifyMeBefore ? "Notify me \(Int(notifyBeforeTime)) \(notifyBeforeTime == 1 ? "minute" :"minutes") before" :"Notify me before", isOn: $notifyMeBefore.animation())
                if (notifyMeBefore) {
                    Slider(value: $notifyBeforeTime,
                           in: 1...30,
                           step: 1,
                           minimumValueLabel: Text("1 min"),
                           maximumValueLabel: Text("30 min"),
                           label: { Text("Minutes before") }
                    )
                }
                
                Toggle("Notify me when \(map.mapName()) is available", isOn: $notifyMeUponChange)
                
                Button("Enable a one time notification") {
                    if (notifyMeUponChange) {
                        addNotification(time: Date.now.distance(to: map.availableAt), title: "\(map.mapName()) is now available!", subtitle: "Avilable for the next \(Int(map.rotationInterval()/60)) minutes", body: "")
                    }
                    if (notifyMeBefore) {
                        addNotification(time: (Date.now.distance(to: map.availableAt) - Double(notifyBeforeTime * 60)), title: "\(map.mapName()) will be available in \(notifyBeforeTime)) minutes", subtitle: "", body: "")
                    }
                    dismiss()
                }
                .fontWeight(.semibold)
                .buttonStyle(.bordered)
                .controlSize(.large)
                .disabled((!notifyMeBefore && !notifyMeUponChange) || map.isAvailable(at: .now))
            }
            .padding(20)
            
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding()
                        .symbolRenderingMode(.hierarchical)
                        .onTapGesture {
                            dismiss()
                        }
                        
                }
                Spacer()
            }
        }
    }
}

func addNotification(time: Double, title: String, subtitle: String, body: String) {
    let center = UNUserNotificationCenter.current()

    let addRequest = {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.body = body
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: time, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }

    center.getNotificationSettings { settings in
        if settings.authorizationStatus == .authorized {
            addRequest()
        } else {
            center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                if success {
                    addRequest()
                } else {
                    print("Authorization declined")
                }
            }
        }
    }
}
