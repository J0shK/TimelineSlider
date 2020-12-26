//
//  TimelineSliderViewModel.swift
//  TimelineSlider
//
//  Created by Josh Kowarsky on 12/16/20.
//

import SwiftUI

struct TimelineValue {
    let start: CGFloat
    let stop: CGFloat
}

class TimelineSliderViewModel: ObservableObject {
    let handleSize = CGSize(width: 10, height: 30)

    @Published var startPosX: CGFloat
    @Published var stopPosX: CGFloat

    @Published var startPerc: CGFloat = 0
    @Published var stopPerc: CGFloat = 1

    @Published var dragStart: CGFloat = 0
    @Published var dragStop: CGFloat = 0

    @Published var playheadPerc: CGFloat = 0

    var updatedHandler: ((TimelineValue) -> Void)?

    init() {
        startPosX = handleSize.width / 2
        stopPosX = handleSize.width / 2
    }

    func startDragChanged(gesture: DragGesture.Value, geometry: GeometryProxy) {
        startPosX = min(max(handleSize.width / 2, gesture.location.x), geometry.size.width + stopPosX - (handleSize.width * 2))

        setPercentages(geometry: geometry)
    }

    func stopDragChanged(gesture: DragGesture.Value, geometry: GeometryProxy) {
        stopPosX = max(min(handleSize.width / 2, gesture.location.x), -geometry.size.width + startPosX + (handleSize.width * 2))

        setPercentages(geometry: geometry)
    }

    func blockDragChanged(gesture: DragGesture.Value, geometry: GeometryProxy) {
        if (dragStart == 0) {
            dragStart = startPosX
            dragStop = stopPosX
        }
        let startPosXDelta = gesture.translation.width + dragStart
        let stopPosXDelta = gesture.translation.width + dragStop

        guard startPosXDelta > handleSize.width / 2, stopPosXDelta < handleSize.width / 2 else { return }

        startPosX = startPosXDelta
        stopPosX = stopPosXDelta

        setPercentages(geometry: geometry)
    }

    func blockDragEnded(gesture: DragGesture.Value) {
        dragStart = 0
        dragStop = 0
    }

    private func setPercentages(geometry: GeometryProxy) {
        let startPerc = (startPosX - (handleSize.width / 2)) / geometry.size.width
        self.startPerc = startPerc.rounded()

        let stopPerc = 1 - (abs(stopPosX - (handleSize.width / 2)) / geometry.size.width)
        self.stopPerc = stopPerc.rounded()

        updatedHandler?(TimelineValue(start: startPerc, stop: stopPerc))
    }
}

private extension CGFloat {
    func rounded(_ places: Int = 3) -> CGFloat {
        let divisor = pow(10.0, Double(places))
        return CGFloat((Double(self) * divisor).rounded() / divisor)
    }
}
