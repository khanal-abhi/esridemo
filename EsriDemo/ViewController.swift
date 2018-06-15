//
//  ViewController.swift
//  EsriDemo
//
//  Created by Abhinash Khanal on 6/14/18.
//  Copyright © 2018 Abhinash.io. All rights reserved.
//

import UIKit
import ArcGIS
import CoreLocation

class ViewController: UIViewController {
    @IBOutlet weak var mapView: AGSMapView!

    var locationManager = CLLocationManager()
    var graphicsOverlay: AGSGraphicsOverlay!
    var marker: AGSGraphic!
    var lastLocation: CLLocation!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.mapView.map = AGSMap(basemapType: .openStreetMap, latitude: 72, longitude: -42, levelOfDetail: 13)
        graphicsOverlay = AGSGraphicsOverlay()
        self.mapView.graphicsOverlays.add(graphicsOverlay)
        let circle = AGSSimpleMarkerSymbol(style: .circle, color: .white, size: 40)
        circle.outline = AGSSimpleLineSymbol(style: .solid, color: .blue, width: 2)

        let geometry = AGSPoint(clLocationCoordinate2D: CLLocationCoordinate2DMake(-42, 73))
        marker = AGSGraphic(geometry: geometry, symbol: circle)

        locationManager.delegate = self
        locationManager.showsBackgroundLocationIndicator = true
        locationManager.requestAlwaysAuthorization()
        self.mapView.setViewpointScale(3, completion: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func updateMapLocation(location: CLLocation?) {
        if let coordinate = location?.coordinate {
            graphicsOverlay.graphics.remove(marker)
            marker.geometry = AGSPoint(clLocationCoordinate2D: coordinate)
            graphicsOverlay.graphics.add(marker)
            mapView.setViewpointCenter(AGSPoint(clLocationCoordinate2D: coordinate), completion: nil)

        }
    }

    private func addPath(location: CLLocation?) {
        guard let lastLocation = self.lastLocation, let newLocation = location else {
            return
        }
        let path = AGSPolyline(points: [AGSPoint(clLocationCoordinate2D: lastLocation.coordinate), AGSPoint(clLocationCoordinate2D: newLocation.coordinate)])
        let line = AGSSimpleLineSymbol(style: .solid, color: .blue, width: 5)

        let pg = AGSGraphic(geometry: path, symbol: line, attributes: ["cap": "round", "join": "round"])
        graphicsOverlay.graphics.add(pg)
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let ll = locations.first {
            addPath(location: ll)
            lastLocation = ll
        }
        updateMapLocation(location: locations.first)
//        mapView.locationDisplay.dataSource = self
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        mapView.setViewpointRotation(newHeading.trueHeading.truncatingRemainder(dividingBy: 360), completion: { (done) in
            //
        })
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            manager.requestAlwaysAuthorization()
            fallthrough
        case .authorizedAlways:
            manager.allowsBackgroundLocationUpdates = true
            manager.startUpdatingLocation()
            manager.startUpdatingHeading()
        case .notDetermined:
            manager.requestAlwaysAuthorization()
        case .denied:
            manager.requestWhenInUseAuthorization()
        default:
            break
        }
    }
}

