//
//  ProgressHelper.swift
//  MapTimer
//
//  Created by Jack Kroll on 4/9/25.
//

import SwiftUI

struct ProgressHelper: View {
    @State var debugDelay = 5
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var body: some View {
        ProgressView()
        Text(debugDelay > 0 ? " " : "Your network may be unstable")
            .onReceive(timer) { _ in
                if (debugDelay > 0) {
                    withAnimation {
                        debugDelay -= 1
                    }
                }
            }
            .fontWeight(.semibold)
            .foregroundStyle(.orange)
            .multilineTextAlignment(.center)
            .transition(.opacity)
    }
}

#Preview {
    ProgressHelper()
}
