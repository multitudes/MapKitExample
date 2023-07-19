# MapKitExample
Inspired by the WWDC23 talk Meet MapKit for SwiftUI

1 - remove the boilerplate code, import MapKit and add `Map()`.  
2- Add a marker on a specific coordinate:
```swift
extension CLLocationCoordinate2D {
    static let parking = CLLocationCoordinate2D(latitude: 42.354528, longitude: -71.068369)
}
```
3- Use Map content builder closure to add the marker to the map. 
 

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
And there are Mapcircle and MapPolyline.
```swift
            MapCircle (center: islandCenter, radius: islandRadius)
                .foregroundStyle(.orange.opacity(0.75))
            MapPolyline (coordinates: sidewalk)
                .stroke(.blue, linewidth: 13)
```
