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

extension MKCoordinateRegion {
    static let boston = MKCoordinateRegion (
        center: CLLocationCoordinate2D( latitude: 42.360256, longitude: -71.057279),
        span: MKCoordinateSpan ( latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    static let northShore = MKCoordinateRegion (
        center: CLLocationCoordinate2D( latitude: 42.547408, longitude: -70.870085),
        span: MKCoordinateSpan( latitudeDelta: 0.5, longitudeDelta: 0.5)
    )
}

struct ContentView: View {
    @State private var position: MapCameraPosition = .automatic
    @State private var searchResults: [MKMapItem] = []
    
    var body: some View {
        Map(position: $position) {
            Annotation("Parking",coordinate: .parking, anchor: .center) {
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.background)
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(.secondary, lineWidth: 5)
                    Image(systemName: "car")
                        .padding(5)
                }
            }
            .annotationTitles(.hidden)
            
            ForEach(searchResults, id: \.self) { result in
                Marker(item: result)
            }
        }
        .mapStyle(.standard(elevation: .realistic))
        .safeAreaInset(edge: .bottom) {
            HStack {
                Spacer()
                BeanTownButtons(position: $position, searchResults: $searchResults)
                    .padding(.top)
                Spacer()
            }
            .background(.ultraThinMaterial)
        }
        .onChange(of: searchResults) {
            position = .automatic
        }
    }
}

#Preview {
    ContentView()
}
