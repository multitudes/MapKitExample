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
    @State private var searchResults: [MKMapItem] = []
    
    var body: some View {
        Map {
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
                BeanTownButtons(searchResults: $searchResults)
                    .padding(.top)
                Spacer()
            }
            .background(.ultraThinMaterial)
        }
    }
        


}

#Preview {
    ContentView()
}
