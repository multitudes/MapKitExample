//
//  BeanTownButtons.swift
//  MapKitExample
//
//  Created by Laurent B on 19/07/2023.
//

import MapKit
import SwiftUI

struct BeanTownButtons: View {
    @Binding var position: MapCameraPosition
    @Binding var searchResults: [MKMapItem]
    
    var body: some View {
        HStack {
            Button {
                search(for: "playground")
            } label: {
                Label ("Playgrounds", systemImage: "figure.and.child.holdinghands")
            }
            .buttonStyle(.borderedProminent)
            
            Button {
                search(for: "beach")
            } label: {
                Label ("Beaches", systemImage: "beach.umbrella")
            }
            .buttonStyle(.borderedProminent)
            
            Button {
                position = .region(.boston)
            } label: {
                Label("Boston", systemImage: "building.2")
            }
            .buttonStyle(.bordered)
            
            Button {
                position = .region(.northShore)
            } label: {
                Label("North Shore", systemImage: "water.waves")
            }
            .buttonStyle (.bordered)
        }
        .labelStyle (.iconOnly)
    }
    
    func search(for query: String) {
        let request = MKLocalSearch.Request ()
        request.naturalLanguageQuery = query
        request.resultTypes = .pointOfInterest
        request.region = MKCoordinateRegion (
            center: .parking,
            span: MKCoordinateSpan (latitudeDelta: 0.0125, longitudeDelta: 0.0125))
        
        Task {
            let search = MKLocalSearch (request: request)
            let response = try? await search.start ()
            searchResults = response?.mapItems ?? []
        }
    }
}

#Preview {
    BeanTownButtons(position: .constant(.automatic), searchResults: .constant([]))
}
