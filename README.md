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
