//
//  MapViewController.swift
//  BusSP
//
//  Created by Douglas Cardoso Ferreira on 16/07/20.
//  Copyright © 2020 Douglas Cardoso. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    enum MapMessageType {
        case routeError
        case authorizationWarning
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var viInfo: UIView!
    @IBOutlet weak var lbNameLine: UILabel!
    @IBOutlet weak var lbNumberCar: UILabel!
    @IBOutlet weak var lbAccessible: UILabel!
    @IBOutlet weak var aiLoading: UIActivityIndicatorView!
    
    // MARK: - Properties
    var bus: Bus!
    var busPositions: BusPosition?
    var busLocations: [Location] = []
    lazy var locationManager = CLLocationManager()
    var btUserLocation: MKUserTrackingButton!
    var selectedAnnotation: BusAnnotation?

    override func viewDidLoad() {
        super.viewDidLoad()
        viInfo.isHidden = true
        mapView.mapType = .mutedStandard
        mapView.delegate = self
        locationManager.delegate = self
        
        loadBusesInMap()
        
        configureLocationButton()
        requestUserLocationAuthorization()
        
    }
    
    func loadBusesInMap(_ termosBusca: String = "") {
        if !termosBusca.isEmpty {
            SPTransOlhoVivo.autenticar { (response) in
                SPTransOlhoVivo.posicaoDosVeiculos(self.bus.cl, onComplete: { (busPositions) in
                    self.busPositions = busPositions
                    let count = self.busPositions!.vs.count
                    var i = 0
                    while i < count {
                        self.addToMap(self.busPositions!.vs[i])
                        i+=1
                    }
                }) { (error) in
                    print(error)
                }
            }
        }
    }
    
//    func desenhar() {
//        //Desenhar linha no mapa
//        if CLLocationManager.authorizationStatus() !=  .authorizedWhenInUse {
//            showAlert(type: .authorizationWarning)
//            return
//        }
//
//        let request = MKDirections.Request()
//        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: self.locBus.first!.coordinate))
//        request.source = MKMapItem(placemark: MKPlacemark(coordinate: self.locBus.last!.coordinate))
//        let directions = MKDirections(request: request)
//        directions.calculate { (response, error) in
//            if error == nil {
//                if let response = response {
//                    //self.mapView.removeOverlay(self.mapView.overlays as! MKOverlay)
//
//                    let route = response.routes.first
//
//                    self.mapView.addOverlay(route!.polyline, level: .aboveRoads)
//                    var annotations = self.mapView.annotations.filter({($0 is Location)})
//                    //annotations.append(self.selectedAnnotation as! MKAnnotation)
//                    self.mapView.showAnnotations(annotations, animated: true)
//
//                }
//            } else {
//                self.showAlert(type: .routeError)
//            }
//        }
//    }
    
    func configureLocationButton() {
        btUserLocation = MKUserTrackingButton(mapView: mapView)
        btUserLocation.backgroundColor = .white
        btUserLocation.frame.origin.x = 10
        btUserLocation.frame.origin.y = 10
        btUserLocation.layer.cornerRadius = 5
        btUserLocation.layer.borderWidth = 1
        btUserLocation.layer.borderColor = UIColor(named: "main")?.cgColor
    }
    
    func addToMap(_ busPos: Location) {
        let annotation = BusAnnotation(coordinate: busPos.coordinate, type: .bus)
        annotation.prefix = "Prefixo do veículo: \(busPos.p)"
        annotation.accessible = "Acessivel: \(busPos.a == true ? "Sim" : "Não")"
        mapView.addAnnotation(annotation)
    }
    
    func showBus() {
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    func requestUserLocationAuthorization() {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
                case .authorizedAlways, .authorizedWhenInUse:
                    mapView.addSubview(btUserLocation)
                case .denied:
                    showAlert(type: .authorizationWarning)
                case .notDetermined:
                    locationManager.requestWhenInUseAuthorization()
                case .restricted:
                    break
            }
        } else {
            //Não dá
        }
    }
    
    func showAlert(type: MapMessageType) {
        let title = type == .authorizationWarning ? "Aviso" : "Erro"
        let message = type == .authorizationWarning ? "Para usar os recursos de localização do App, você precisa permitir o uso na tela de Ajustes" : "Não foi possível encontrar esta rota"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        if type == .authorizationWarning {
            let confirmAction = UIAlertAction(title: "Ir para Ajustes", style: .default, handler: { (action) in
                if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
                }
            })
            alert.addAction(confirmAction)
        }
        present(alert, animated: true, completion: nil)
    }
    
    func showInfo() {
        lbNameLine.text = bus.sl == 1 ? "\(bus.lt)-\(bus.tl) / \(bus.tp)" : "\(bus.lt)-\(bus.tl) / \(bus.ts)"
        lbNumberCar.text = selectedAnnotation!.prefix
        lbAccessible.text = selectedAnnotation!.accessible
        viInfo.isHidden = false
    }
    
}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is BusAnnotation) {
            return nil
        }
        let type = (annotation as! BusAnnotation).type
        let identifier = "\(type)"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        annotationView?.annotation = annotation
        annotationView?.canShowCallout = true
        annotationView?.markerTintColor = type == .bus ? UIColor(named: "main") : UIColor(named: "busStop")
        annotationView?.glyphImage = type == .bus ? UIImage(named: "busGlyph") : UIImage(named: "busStopGlyph")
        annotationView?.displayPriority = type == .bus ? .required : .defaultHigh
        return annotationView
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        selectedAnnotation = (view.annotation as! BusAnnotation)
        showInfo()
    }
    
//    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//        if overlay is MKPolyline {
//            let renderer = MKPolylineRenderer(overlay: overlay)
//            renderer.strokeColor = UIColor(named: "main")?.withAlphaComponent(0.8)
//            renderer.lineWidth = 5.0
//            return renderer
//        }
//        return MKOverlayRenderer(overlay: overlay)
//    }
    
    
    
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            case .authorizedAlways, .authorizedWhenInUse:
                mapView.showsUserLocation = true
                mapView.addSubview(btUserLocation)
                locationManager.startUpdatingLocation()
            default:
                break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let region = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: CLLocationDistance(exactly: 500)!, longitudinalMeters: CLLocationDistance(exactly: 500)!)
            mapView.setRegion(region, animated: true)
        }
    }
}
