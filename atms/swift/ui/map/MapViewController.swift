import UIKit
import MapKit
import RxSwift
import RxCocoa


class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var zoomFurther: UIView!
    
    @IBOutlet weak var progress: UIActivityIndicatorView!
    
    @IBOutlet weak var zoomFurtherLabel: UILabel!
    
    let disposeBag = DisposeBag()
    
    var viewModel: MainViewModel!
    
    var locationSet = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        zoomFurtherLabel.text = "zoom_further".localized
        
        progress.color = UIColor.purple
        
        mapView.delegate = self
        mapView.tintColor = UIColor.purple
        mapView.layoutMargins = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        
        zoomFurther.layer.cornerRadius = 12
        zoomFurther.layer.shadowRadius = 1
        zoomFurther.layer.shadowColor = UIColor.black.cgColor
        zoomFurther.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        zoomFurther.layer.shadowOpacity = 0.33
        
        zoomFurther.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        zoomFurther.alpha = 0
        
        viewModel.zoomfurther().bind { [unowned self] show in
            
            if (show) {
                UIView.animate(withDuration: 0.6,
                               animations: {
                                self.zoomFurther.transform = CGAffineTransform.identity
                                self.zoomFurther.alpha = 1.0
                }, completion: nil)
                
            } else {
                
                UIView.animate(withDuration: 0.6,
                               animations: {
                                self.zoomFurther.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                                self.zoomFurther.alpha = 0
                }, completion: nil)
                
            }
            }.disposed(by: disposeBag)
        
        viewModel.atms()
            .bind { [unowned self] pois in
                
                var poiCopy = Set<AtmNode>(pois)
                
                let currentAnnotations = self.mapView.annotations
                    .compactMap({ annotation -> [AtmAnnotation] in
                        
                        if let atmAnnotation = annotation as? AtmAnnotation {
                            return [atmAnnotation]
                        }
                        
                        if let cluster = annotation as? MKClusterAnnotation {
                            
                            return cluster.memberAnnotations.filter {
                                $0 is AtmAnnotation
                                } as! [AtmAnnotation]
                        }
                        
                        return []
                    }).joined()
                
                for atmAnnotation in currentAnnotations {
                    if pois.contains(atmAnnotation.atmNode) {
                        poiCopy.remove(atmAnnotation.atmNode)
                    } else {
                        self.mapView.removeAnnotation(atmAnnotation)
                    }
                }
                
                self.mapView.addAnnotations(poiCopy.map({
                    let poiLocation = CLLocationCoordinate2DMake($0.lat, $0.lon)
                    
                    let pin = AtmAnnotation(atmNode: $0)
                    pin.coordinate = poiLocation
                    pin.title = $0.tags.name
                    
                    return pin
                }))
                
                
            }.disposed(by: disposeBag)
        
        viewModel.selectedAtm().bind { [unowned self] atmNode in
            
            guard atmNode != nil else {
                self.mapView.layoutMargins = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
                
                if let selectedAnnotation = self.mapView.selectedAnnotations.first {
                    self.mapView.deselectAnnotation(selectedAnnotation, animated: true)
                }
                
                return
            }
            
            if let selectedAnnotation = self.mapView.annotations.first(where: { annotation in
                
                if let atmAnnotation = annotation as? AtmAnnotation {
                    return atmAnnotation.atmNode == atmNode!
                } else {
                    return false
                }
                
            }) {
                self.mapView.layoutMargins = UIEdgeInsets(top: 64, left: 0, bottom: 256, right: 0)
                self.mapView.showAnnotations([selectedAnnotation], animated: true)
                self.mapView.selectAnnotation(selectedAnnotation, animated: true)
            }
            }.disposed(by: disposeBag)
        
        
        viewModel.progress()
            .bind { [unowned self] in
                if $0 {
                    self.progress.startAnimating()
                } else {
                    self.progress.stopAnimating()
                }
            }.disposed(by: disposeBag)
        
        viewModel.locationPermissionObservable()
            .bind { [unowned self] in
                self.mapView.showsUserLocation = $0
            }.disposed(by: disposeBag)
    }
    
    
}

extension MapViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !(annotation is MKUserLocation) else {
            return nil
            
        }
        
        let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier, for: annotation)
        
        dequeuedView.clusteringIdentifier = "clusterid"
        
        if let markerView = dequeuedView as? MKMarkerAnnotationView {
            markerView.markerTintColor = UIColor.accent
        }
        
        return dequeuedView
    }
    
    func mapView(_ mapView: MKMapView, clusterAnnotationForMemberAnnotations memberAnnotations: [MKAnnotation]) -> MKClusterAnnotation {
        
        let clusterAnnotation =  MKClusterAnnotation(memberAnnotations: memberAnnotations)
        
        return clusterAnnotation
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        let rect = mapView.visibleMapRect
        
        let startPoint = MKMapPoint(x: rect.origin.x, y: MKMapRectGetMaxY(rect))
        
        let endPoint = MKMapPoint(x: MKMapRectGetMaxX(rect), y: rect.origin.y)
        
        let startCoordinates = MKCoordinateForMapPoint(startPoint)
        
        let endCoordinates = MKCoordinateForMapPoint(endPoint)
        
        let zoom = mapView.currentZoomLevel
        
        let viewPort = ViewPort(lngStart: startCoordinates.longitude, latStart: startCoordinates.latitude, lngEnd: endCoordinates.longitude, latEnd: endCoordinates.latitude)
        
        viewModel.zoom = zoom
        
        viewModel.viewPort = viewPort
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if let atmAnnotation = view.annotation as? AtmAnnotation {
            
            viewModel.select(atmNode: atmAnnotation.atmNode)
        }
        
        if let clusterAnnotation = view.annotation as? MKClusterAnnotation {
            
            mapView.showAnnotations(clusterAnnotation.memberAnnotations, animated: true)
        }
        
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        if (!locationSet) {
            let region =  MKCoordinateRegion(center: mapView.userLocation.coordinate, span: MKCoordinateSpanMake(0.09, 0.09))
            
            mapView.setRegion(region, animated: true)
            
            locationSet = true
            
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        viewModel.clearSelectedAtm()
    }

}



