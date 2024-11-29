//
//  SunburstView.swift
//  SunburstDiagram
//
//  Created by Ludovic Landry on 6/10/19.
//  Copyright © 2019 Ludovic Landry. All rights reserved.
//

import SwiftUI

public struct SunburstView: View {

    @ObservedObject var sunburst: Sunburst
    
    public init(configuration: SunburstConfiguration) {
        sunburst = configuration.sunburst
    }
    
    public var body: some View {
        let arcs = ZStack {
            configureViews(arcs: sunburst.rootArcs)
            
            // Stop the window shrinking to zero when there is no arcs.
            Spacer()
        }
        .flipsForRightToLeftLayoutDirection(true)
        .padding()

        let drawnArcs = arcs.drawingGroup()
        return drawnArcs
    }
    
    private func configureViews(arcs: [Sunburst.Arc], parentArc: Sunburst.Arc? = nil) -> some View {
        return ForEach(arcs) { arc in
            ArcView(arc: arc, configuration: self.sunburst.configuration)
                .onTapGesture {
                    guard self.sunburst.configuration.allowsSelection else { return }
                    if self.sunburst.configuration.selectedNode == arc.node && self.sunburst.configuration.focusedNode == arc.node {
                        self.sunburst.configuration.focusedNode = self.sunburst.configuration.parentForNode(arc.node)
                    } else if self.sunburst.configuration.selectedNode == arc.node {
                        self.sunburst.configuration.focusedNode = arc.node
                    } else {
                        self.sunburst.configuration.selectedNode = arc.node
                    }
                }
            IfLet(arc.childArcs) { childArcs in
                AnyView(self.configureViews(arcs: childArcs, parentArc: arc))
            }
        }
    }
}

#if DEBUG
struct SunburstView_Previews : PreviewProvider {
    static var previews: some View {
        let configuration = SunburstConfiguration(nodes: [
            Node(name: "10 %",
                 showName: true,
                 value: 10.0,
                 textColor: .green,
                 backgroundColor: .green.withAlphaComponent(0.3),
                 children: [
                    .init(name: "", value: 10, backgroundColor: .green)
                 ]
                ),
            Node(name: "20 %",
                 showName: true,
                 value: 30.0,
                 textColor: .red,
                 backgroundColor: .red.withAlphaComponent(0.3),
                 children: [
                    .init(name: "", value: 30, backgroundColor: .red)
                 ]
                ),
            Node(name: "70 %",
                 showName: true,
                 value: 75.0,
                 textColor: .blue,
                 backgroundColor: .blue.withAlphaComponent(0.3),
                 children: [
                    .init(name: "", value: 75, backgroundColor: .blue)
                 ]
                )
        ], calculationMode: .parentDependent(totalValue: 115.0))
        configuration.maximumExpandedRingsShownCount = 1
        configuration.expandedArcThickness = 26
        configuration.collapsedArcThickness = 10
        configuration.maximumRingsShownCount = 2
        configuration.textFont = .system(size: 12, weight: .medium)
        return SunburstView(configuration: configuration)
    }
}
#endif
