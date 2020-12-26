//
//  ContentView.swift
//  TimelineSlider
//
//  Created by Josh Kowarsky on 12/16/20.
//

import AVKit
import SwiftUI

class ContentViewModel: ObservableObject {
    @Published var currentTimePerc: CGFloat = 0
    var player: AVPlayer?
    var duration: CMTime?

    private var timeObserver: Any?
    private var startTime: CMTime?
    private var stopTime: CMTime?

    init() {
        guard let url = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8") else { return }
        let asset = AVAsset(url: url)
        duration = asset.duration
        let item = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: item)
        timeObserver = player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(0.01, preferredTimescale: .max), queue: nil, using: { [weak self] time in
            self?.currentTimePerc = CGFloat(CMTimeGetSeconds(self?.player?.currentTime() ?? .zero) / CMTimeGetSeconds(self?.duration ?? .zero))
            guard let stopTime = self?.stopTime, let startTime = self?.startTime, time >= stopTime else { return }
            self?.player?.seek(to: startTime)
        })
    }

    func set(start: CMTime, stop: CMTime) {
        player?.seek(to: start)
        startTime = start
        stopTime = stop
    }
}

struct ContentView: View {
    @ObservedObject var viewModel = ContentViewModel()
    private var timelineViewModel = TimelineSliderViewModel()

    var body: some View {
        VStack {
            VideoPlayer(player: viewModel.player)
                .padding()
            TimelineSlider(viewModel: timelineViewModel)
                .playheadPosition(viewModel.currentTimePerc)
                .onUpdate { value in
                    guard let duration = viewModel.duration else { return }
                    let seconds = CMTimeGetSeconds(duration)
                    let newCMStartTime = CMTimeMakeWithSeconds(seconds * Double(value.start), preferredTimescale: .max)
                    let newCMStopTime = CMTimeMakeWithSeconds(seconds * Double(value.stop), preferredTimescale: .max)
                    viewModel.set(start: newCMStartTime, stop: newCMStopTime)
                }
                .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().frame(width: 300)
    }
}
