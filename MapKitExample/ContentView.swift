//
//  ContentView.swift
//  MapKitExample
//
//  Created by Laurent B on 19/07/2023.
//

import MapKit
import SwiftUI

extension CLLocationCoordinate2D {
    static let parking = CLLocationCoordinate2D(latitude: 42.354528, longitude: -71.068369)
}

struct ContentView: View {
    var body: some View {
        Map {
            Marker("Parking", coordinate: .parking)
        }
    }
}

#Preview {
    ContentView()
}
