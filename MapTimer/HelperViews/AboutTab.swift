//
//  AboutTab.swift
//  MapTimer
//
//  Created by Jack Kroll on 4/9/25.
//

import SwiftUI

struct AboutTab: View {
    var body: some View {
        VStack {
            ScrollView{
                VStack(alignment: .leading) {
                    Text("Disclaimer")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("The project and people involved are not sponsored, affiliated or endorsed by EA/Respawn/EAC in any way. This is made by a player, for players. All images, icons and trademarks belong to their respective owner. Apex Legends is a registered trademark of EA. Game assets, materials and icons belong to Electronic Arts. Be aware, EA and Respawn do not endorse the content of this website nor are responsible for this content.")
                }
                Divider()
                VStack(alignment: .leading) {
                    Text("Experiencing Issues?")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("This project relys upon my server being up to date, due to this there may be some delay after a update. However, please reach out to me if there are prolonged issues or you encounter other issues")
                    Button("Report Issue") {
                        UIApplication.shared.open(URL(string: "mailto:support@jackk.dev?subject=Map%20Timer%20Issue")!)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
            }
        }
    }
}

#Preview {
    AboutTab()
}
