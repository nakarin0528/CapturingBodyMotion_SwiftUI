//
//  ContentView.swift
//  CoolMotion
//
//  Created by yiheng on 2021/01/19.
//

import SwiftUI
import RealityKit
import ARKit
import Combine

struct ContentView : View {
    @State var offsetValue:Float = 0.0
    
    var body: some View {
        return BodyCaptureViewContainer(offsetValue: $offsetValue).edgesIgnoringSafeArea(.all)
    }
}


#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
