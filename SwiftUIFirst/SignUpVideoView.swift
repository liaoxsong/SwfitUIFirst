//
//  SignUpVideoView.swift
//  Pheel
//
//  Created by Song Liao on 7/9/20.
//  Copyright © 2020 Pheel / Salud Network Inc. All rights reserved.
//
import SwiftUI
import AVKit
import AVFoundation

struct SignUpVideoView: View {
    var body: some View {
        ZStack {
            SignUpVideoController()
            Rectangle().colorMultiply(Color.black.opacity(0.4))//0.4 is for testing, actual is 0.9
        }
    }
}

struct SignUpVideoView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            SignUpVideoView()
        }
    }
}

final class SignUpVideoController : UIViewControllerRepresentable {
    var playerLooper: AVPlayerLooper?

    func makeUIViewController(context: UIViewControllerRepresentableContext<SignUpVideoController>) ->
        AVPlayerViewController {
            let controller = AVPlayerViewController()
            controller.showsPlaybackControls = false

            guard let path = Bundle.main.path(forResource: "drone", ofType: "mov") else {
                debugPrint("drone.mov not found")
                return controller
            }

            let asset = AVAsset(url: URL(fileURLWithPath: path))
            let playerItem = AVPlayerItem(asset: asset)
            let queuePlayer = AVQueuePlayer()
            // OR let queuePlayer = AVQueuePlayer(items: [playerItem]) to pass in items
            queuePlayer.isMuted = true

            playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
            queuePlayer.play()
            controller.player = queuePlayer

            return controller
        }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: UIViewControllerRepresentableContext<SignUpVideoController>) {
    }
}
