# Meet MapKit for SwiftUI
Notes from the WWDC23 talk Meet MapKit for SwiftUI
 
## Part 1

MapKit already has introduced some new improvement in iOS16, like the new 3D city experience and new overlays options. In iOS17 and macOS 14, MapKit goes to a new level introducing a few new addition for SwiftUI.

The notes below are from the WWDC23 session: "Meet MapKit for SwiftUI" intended for personal use only. It is a fantastic presentation going from zero to a full functioning app in just 30 minutes. There was no code transcription or download avalaible so I typed along. 
I think the new API are fantastic. Lets see them in action! 


We make a new project in Xcode. The exciting thing here is that I can straightaway start with a universal app. I remove the boilerplate code, import MapKit and add `Map()` to the `ContentView()` and this alone is already enough to show the map in the preview. I love maps! :)
  
How to add a marker on a specific coordinate:
```swift
extension CLLocationCoordinate2D {
    static let parking = CLLocationCoordinate2D(latitude: 42.354528, longitude: -71.068369)
}
```


Using the MapContentBuilder closure to add the marker to the map. 

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
            .foregroundStyle(.purple)
```

I will use annotation instead of Marker to display a custom image:
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

I can use mapStyle to display satellite or flyover imagery as well. There are a few options: `.mapStyle(.standard)`,`.mapStyle(.standard(.realistic))`, `.mapStyle (.imagery (elevation: .realistic))`, `.mapStyle (.hybrid(elevation: .realistic))`. 

I create some button views to use in the search feature of the map:
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
and our search function will use a Binding and MKLocalSearch to find places on my map and will look like this:
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
```swift
Map {
    Marker ("Parking", systemImage: "car.fill", coordinate: parking)
        .tint (.mint)

    Marker ("Foot Bridge", monogram: "FB" coordinate: bridge)
        .tint (.blue)

    Marker("Ducklings", image: "DucklingAsset" coordinate: ducklings)
        .tint(.orange)
}
```

I control what place or region is displayed, and discover if the user has interacted with:    
`@State private var position: MapCameraPosition = .automatic`
and  
`Map(position: $position) {...`  

```swift
        .onChange(of: searchResults) {
            position = .automatic
        }
```

next we create regions:  

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

We control what place or region is displayed with:  
- automatic  
- region (MKCoordinateRegion)  
- rect (MKMapRect)  
- item (MKMapItem)  
- camera (MapCamera)  
- userLocation( )  



### Links
[WWDC23 - Meet MapKit for SwiftUI](https://developer.apple.com/videos/play/wwdc2023/10043/)

[WWDC22 - What's new in MapKit](https://developer.apple.com/videos/play/wwdc2022/10035/)

[MapKit docs](https://developer.apple.com/documentation/mapkit)
[MapKit for SwiftUI docs](https://developer.apple.com/documentation/mapkit/mapkit_for_swiftui)
