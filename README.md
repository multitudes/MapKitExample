# MapKitExample
Inspired by the WWDC23 talk Meet MapKit for SwiftUI

1 - remove the boilerplate code, import MapKit and add `Map()`.  
2- Add a marker on a specific coordinate:
```swift
extension CLLocationCoordinate2D {
    static let parking = CLLocationCoordinate2D(latitude: 42.354528, longitude: -71.068369)
}
```
3- Use the MapContentBuilder closure to add the marker to the map. 
 

```swift
            Map {
                Marker("Parking", coordinate: .parking)
            }
```
4- What is a Marker: A Marker is used to present content at a precise coordinate on the map.
```swift
        Map {
            Marker ("Sign-in", systemImage: "figure.wave", coordinate: signIn)
        }
``` 
Annotations can display a SwiftUI view at a certain coordinate.   
```swift
            Annotation (
                "Sign-in", coordinate: signIn, anchor: bottom
            ) {
                Image (systemName: "figure.wave")
                    .padding (4)
                    .foregroundStyle(.white)
                    .background (Color.indigo)
                    .cornerRadius (4)
            }
```
And there are Mapcircle, MapPolyline and MapPolygon.
```swift
            MapCircle (center: islandCenter, radius: islandRadius)
                .foregroundStyle(.orange.opacity(0.75))
            
            MapPolyline (coordinates: sidewalk)
                .stroke(.blue, linewidth: 13)
                
            MapPolygon (coordinates: dock)
        .       .foregroundStyle(.purple)
```

4- I will use annotation instead of Marker to display a custom image:
```swift
        Annotation("Parking", coordinate: .parking) {
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .fill(.background)
                RoundedRectangle(cornerRadius: 5)
                    .stroke(.secondary, lineWidth: 5)
                Image(systemName: "car")
                    .padding(5)
            }
        }
        .annotationTitles(.hidden) / hide the title leaving the icon only
```
This SwiftUI view will be displayed on the map centered right on the parking coordinate. If you’d like your view to be positioned above the coordinate instead, you can use Annotation’s anchor parameter. Specifying an anchor value of “bottom” will position the bottom of your view right on the annotation’s coordinate.

- use mapStyle to display satellite or flyover imagery as well. There are a few options: `.mapStyle(.standard)`,`.mapStyle(.standard(.realistic))`, `.mapStyle (.imagery (elevation: .realistic))`, `.mapStyle (.hybrid(elevation: .realistic))`. 
- Some button views to use in the search feature of the map:
```swift
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
}
.labelStyle (.iconOnly)

```
- and our search function will use a Binding and MKLocalSearch to find places on my map and will look like this:
```swift
@Binding var searchResults: [MKMapItem]

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
```
- Adding the buttons in the safe area:
```swift
    .safeAreaInset(edge: .bottom) {
        HStack {
            Spacer()
            BeanTownButtons(searchResults: $searchResults)
                .padding(.top)
            Spacer()
        }
        .background(.ultraThinMaterial)
    }
```
- Add the markers
```swift
    ForEach(searchResults, id: \.self) { result in
        Marker(item: result)
    }
```
The search results are MKMapItems, which is the type MapKit APIs like MKLocalSearch use to represent places. Here, I’m using Marker’s map item initializer. Markers created this way use the map item’s name for their title and use information from the map item to show an icon and tint color that represent the place. Most of these search results show as light blue beach umbrella markers. When you’re working with map items, Marker’s automatic content and style support is very convenient. Even if you aren’t using map items, though, you still have control over the Marker’s presentation. By default, Marker shows a map pin icon in its balloon, like you see here. You can provide your own icon using an Image asset or a system image. You can also show up to three letters of text using monogram. You can change the Marker’s color using the tint modifier. 
```
Map {
    Marker ("Parking", systemImage: "car.fill", coordinate: parking)
        .tint (.mint)

    Marker ("Foot Bridge", monogram: "FB" coordinate: bridge)
        .tint (.blue)

    Marker("Ducklings", image: "DucklingAsset" coordinate: ducklings)
        .tint(.orange)
}
```
- Control what place or region is displayed. Discover if the user has interacted.  
`@State private var position: MapCameraPosition = .automatic`
and
`Map(position: $position) {...`  
```swift
        .onChange(of: searchResults) {
            position = .automatic
        }
```

- next create regions
```swift
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
```
Add buttons in the bottom view together with a binding to position
```swift
    `Button {
        position = .region (.boston)
    } label: {
        `Label("Boston", systemImage: "building.2")
    }
    .buttonStyle (.bordered)
        
    Button {
        `position = .region (.northShore)
    } label: {
    `   Label("North Shore", systemImage: "water.waves")
    }
    .buttonStyle (.bordered)      
```

Behind the scenes, what the Map shows is ultimately controlled by a MapCamera. The camera looks at a coordinate on the ground from a certain distance and the orientation of the camera determines what is visible in the map. The app I’m building has not had to create or configure the camera itself. Instead, it simply specifies what should be in view using MapCameraPosition. MapKit takes care of the camera for me. The app uses an automatic camera position to frame content, such as search results. It uses a region position to show Boston and the North Shore. You can specify a camera position to frame other things, as well. Rect position is used to show an area, just like how we’ve used region. It simply uses a map rect to represent that area, instead of a coordinate region. Let’s take a closer look at item, camera, and user location camera positions.

Control what place or region is displayed:  
• automatic  
• region (MKCoordinateRegion)  
• rect (MKMapRect)  
• item (MKMapItem)  
• camera (MapCamera)  
• userLocation ( )  


