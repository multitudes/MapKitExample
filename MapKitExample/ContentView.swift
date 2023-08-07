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

extension MKPolyline {
    static let testPolyline = MKPolyline(coordinates: [
        CLLocationCoordinate2D( latitude: 42.360256, longitude: -71.057279),
        CLLocationCoordinate2D( latitude: 42.36027, longitude: -71.057279),
        CLLocationCoordinate2D( latitude: 42.36027, longitude: -71.0573),
], count: 3)
}

struct ContentView: View {
    @State private var position: MapCameraPosition = .automatic
    @State private var visibleRegion: MKCoordinateRegion?
    @State private var searchResults: [MKMapItem] = []
    @State private var selectedResult: MKMapItem?
    @State private var route: MKRoute?
    
    var body: some View {
        Map(position: $position, selection: $selectedResult) {
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
            .annotationTitles(.hidden)
            
            if let route {
                MapPolyline(route)
                    .stroke(.blue, lineWidth: 5)
            }
            
            MapPolygon(coordinates: [
                CLLocationCoordinate2D(latitude: 42.354528, longitude: -71.068369),
                CLLocationCoordinate2D( latitude: 42.46441, longitude: -70.95092),
                CLLocationCoordinate2D( latitude: 42.50590, longitude: -71.07278),
                CLLocationCoordinate2D(latitude: 42.354528, longitude: -71.068369),
            ])//, contourStyle: .geodesic
            .stroke(.pink, lineWidth: 5)
            .foregroundStyle(.pink.opacity(0.5))
            
            
            MapCircle(center: .parking, radius: 10000)
                .foregroundStyle(.pink.opacity(0.5))
                .stroke(.blue, style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round, miterLimit: 0.5, dash: [0.3], dashPhase: 0.7))
                .mapOverlayLevel(level: .aboveRoads)
            
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
        .mapStyle(.standard(elevation: .realistic))
        .safeAreaInset(edge: .bottom) {
            HStack {
                Spacer()
                VStack(spacing:0) {
                    if let selectedResult {
                        ItemInfoView(selectedResult: selectedResult, route: route)
                            .frame(height: 128)
                            .clipShape(RoundedRectangle (cornerRadius: 10))
                            .padding([.top, .horizontal])
                    }
                    BeanTownButtons(position: $position, searchResults: $searchResults, visibleRegion: visibleRegion)
                        .padding(.top)
                }
                Spacer()
            }
            
            .background(.ultraThinMaterial)
        }
        .onChange(of: searchResults) {
            position = .automatic
        }
        .onChange(of: selectedResult) {
            getDirections()
        }
        .onMapCameraChange { context in
            visibleRegion = context.region
        }
    }
    
    func getDirections() {
        route = nil
        guard let selectedResult else { return }
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: .parking))
        request.destination = selectedResult
        
        Task {
            let directions = MKDirections(request: request)
            let response = try? await directions.calculate()
            route = response?.routes.first
        }
    }
}

#Preview {
    ContentView()
}
