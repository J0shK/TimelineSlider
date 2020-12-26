//
//  TimelineSlider.swift
//  TimelineSlider
//
//  Created by Josh Kowarsky on 12/16/20.
//

import SwiftUI

struct TimelineSlider: View {
    @ObservedObject var viewModel: TimelineSliderViewModel

    var body: some View {
        VStack {
            HStack {
                Text("\(viewModel.startPerc)%")
                Spacer()
                Text("\(viewModel.stopPerc)%")
            }
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .foregroundColor(.clear)
                    Rectangle()
                        .foregroundColor(.yellow)
                        .opacity(0.2)
                        .border(Color.yellow, width: 2)
                        .offset(x: viewModel.startPosX + (viewModel.handleSize.width / 2), y: 0)
                        .frame(width: max(0, geometry.size.width * (viewModel.stopPerc - viewModel.startPerc - ((viewModel.handleSize.width * 2) / geometry.size.width))))
                        .gesture(DragGesture()
                                    .onChanged { gesture in
                                        viewModel.blockDragChanged(gesture: gesture, geometry: geometry)
                                    }
                                    .onEnded { gesture in
                                        viewModel.blockDragEnded(gesture: gesture)
                                    }
                        )
                    Rectangle()
                        .foregroundColor(.black)
                        .offset(x: viewModel.handleSize.width + (viewModel.playheadPerc * geometry.size.width - (viewModel.handleSize.width * 2)), y: 0)
                        .frame(width: 1)
                    HStack(spacing: 0) {
                        Rectangle()
                            .foregroundColor(.clear)
                            .background(RoundedCorners(color: .yellow, topLeft: 10, topRight: 0, bottomLeft: 10, bottomRight: 0))
                            .position(x: viewModel.startPosX, y: viewModel.handleSize.height / 2)
                            .frame(width: viewModel.handleSize.width, height: viewModel.handleSize.height)                        .gesture(DragGesture()
                                        .onChanged({ gesture in
                                            viewModel.startDragChanged(gesture: gesture, geometry: geometry)

                                        })
                            )
                        Spacer()
                        Rectangle()
                            .foregroundColor(.clear)
                            .background(RoundedCorners(color: .yellow, topLeft: 0, topRight: 10, bottomLeft: 0, bottomRight: 10))
                            .position(x: viewModel.stopPosX, y: viewModel.handleSize.height / 2)
                            .frame(width: viewModel.handleSize.width, height: viewModel.handleSize.height)
                            .gesture(DragGesture()
                                        .onChanged({ gesture in
                                            viewModel.stopDragChanged(gesture: gesture, geometry: geometry)
                                        })
                            )
                    }
                }
            }.frame(height: viewModel.handleSize.height)
        }
    }

    func playheadPosition(_ position: CGFloat) -> TimelineSlider {
        viewModel.playheadPerc = position
        return self
    }

    func onUpdate(event: @escaping (TimelineValue) -> Void) -> TimelineSlider {
        viewModel.updatedHandler = event
        return self
    }
}

struct TimelineSlider_Previews: PreviewProvider {
    static var previews: some View {
        TimelineSlider(viewModel: TimelineSliderViewModel()).frame(width: 200)
    }
}

