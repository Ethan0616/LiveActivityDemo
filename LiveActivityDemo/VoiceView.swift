//
//  VoiceView.swift
//  LiveActivityDemo
//
//  Created by Ethan on 2022/10/27.
//

import SwiftUI

struct VoiceView: View {
    var maxHeight: CGFloat = 20.0
    var maxWidth: CGFloat = 20.0
//    var speaker: Speaker = .current
    var voiceList = [0, 0.2, 0.3, 0.4, 0.5]
    var body: some View {
        HStack {
            ForEach(0..<5) { index in
                Spacer()
                Rectangle()
                    .frame(width: maxWidth / 3,
                           height: maxHeight * voiceList[index])
                    .cornerRadius(2.0)
                    .foregroundColor(.yellow)
            }
            Spacer()
        }
        .frame(width: maxWidth, height: maxHeight)
    }
}

struct VoiceView_Previews: PreviewProvider {
    static var previews: some View {
        VoiceView()
    }
}

