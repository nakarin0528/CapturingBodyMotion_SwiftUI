//
//  BodyCaptureViewController.swift
//  CoolMotion
//
//  Created by yiheng on 2021/01/19.
//

import SwiftUI
import RealityKit
import ARKit
import Combine

struct BodyCaptureViewContainer: UIViewRepresentable {
    
    let characterAnchor = AnchorEntity()
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.session.delegate = context.coordinator
        context.coordinator.setCoolGuy()
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        let configuration = ARBodyTrackingConfiguration()
        uiView.session.run(configuration)
        uiView.scene.addAnchor(characterAnchor)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, anchor: characterAnchor)
    }
    
    class Coordinator: NSObject, ARSessionDelegate {
        var character: BodyTrackedEntity?
        let characterAnchor: AnchorEntity
        let characterOffset: SIMD3<Float>
        
        init(_ control: BodyCaptureViewContainer, anchor: AnchorEntity) {
            self.characterAnchor = anchor
            self.characterOffset = [-1.0, 0, 0]
            super.init()
        }
        
        func setCoolGuy() {
            var cancellable: AnyCancellable? = nil
            cancellable = Entity.loadBodyTrackedAsync(named: "character/robot").sink(
                receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        print("Error: Unable to load model: \(error.localizedDescription)")
                    }
                    cancellable?.cancel()
            }, receiveValue: { (character: Entity) in
                if let character = character as? BodyTrackedEntity {
                    character.scale = [1.0, 1.0, 1.0]
                    self.character = character
                    cancellable?.cancel()
                } else {
                    print("Error: Unable to load model as BodyTrackedEntity")
                }
            })
        }
        
        func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
            for anchor in anchors {
                guard let bodyAnchor = anchor as? ARBodyAnchor else { continue }
                
                // Update the position of the character anchor's position.
                let bodyPosition = simd_make_float3(bodyAnchor.transform.columns.3)
                characterAnchor.position = bodyPosition + characterOffset
                // Also copy over the rotation of the body anchor, because the skeleton's pose
                // in the world is relative to the body anchor's rotation.
                characterAnchor.orientation = Transform(matrix: bodyAnchor.transform).rotation
       
                if let character = character, character.parent == nil {
                    // Attach the character to its anchor as soon as
                    // 1. the body anchor was detected and
                    // 2. the character was loaded.
                    characterAnchor.addChild(character)
                }
            }
        }
    }
}
