import UIKit
import MapKit
import RxSwift
import RxCocoa


class MapViewController: UIViewController {
    
    static let topPadding = CGFloat(64.0)
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var zoomFurther: UIView!
    
    @IBOutlet weak var progress: UIActivityIndicatorView!
    
    @IBOutlet weak var zoomFurtherLabel: UILabel!
    
    let disposeBag = DisposeBag()
    
    var viewModel: MainViewModel!
    
    var locationSet = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        zoomFurther.backgroundColor = UIColor.accent
        
        zoomFurtherLabel.text = "zoom_further".localized
        zoomFurtherLabel.textColor = UIColor.white
        
        progress.color = UIColor.purple
        
        mapView.delegate = self
        mapView.tintColor = UIColor.purple
        mapView.layoutMargins = UIEdgeInsets(top: MapViewController.topPadding, left: 0, bottom: 0, right: 0)
        
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
            .distinctUntilChanged()
            .bind { [unowned self] pois in
                
                 var poiCopy = Set<AtmNode>(pois)
                                
                let currentAnnotations = self.mapView.annotations.filter { $0 is AtmAnnotation } as! [AtmAnnotation]
                
                var toRemove: [AtmAnnotation] = []
                
                for atmAnnotation in currentAnnotations {
                    if pois.contains(atmAnnotation.atmNode) {
                        poiCopy.remove(atmAnnotation.atmNode)
                    } else {
                        toRemove.append(atmAnnotation)
                    }
                }
                
                self.mapView.removeAnnotations(toRemove)
                
                self.mapView.addAnnotations(pois.map({
                    let poiLocation = CLLocationCoordinate2DMake($0.lat, $0.lon)
                    
                    let pin = AtmAnnotation(atmNode: $0)
                    pin.coordinate = poiLocation
                    pin.title = $0.tags.name
                    
                    return pin
                }))
                
                
            }.disposed(by: disposeBag)
        
        viewModel.selectedAtm()
            .bind { [unowned self] atmNode in
            
            guard atmNode != nil else {

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
                self.mapView.layoutMargins = UIEdgeInsets(top: MapViewController.topPadding, left: 0, bottom: DrawerViewController.drawerHeight, right: 0)
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
        
        let id = "pin"
        
        var dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: id )
        
        if dequeuedView == nil {
            dequeuedView = MKAnnotationView(annotation: annotation, reuseIdentifier: id)
        }
        else {
            dequeuedView?.annotation = annotation
        }
        
        dequeuedView?.image = UIImage(named: "pin")
        
        return dequeuedView
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
            
            view.image = UIImage(named: "pin_selected")
        }
        
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        if (!locationSet) {
            
            mapView.setCenterCoordinate(mapView.userLocation.coordinate, withZoomLevel: MainViewModel.targetZoomLevel, animated: true)
                        
            locationSet = true
            
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        
        guard !(view.annotation is MKUserLocation) else {
            return
        }
        
        view.image = UIImage(named: "pin")
        
        mapView.layoutMargins = UIEdgeInsets(top: MapViewController.topPadding, left: 0, bottom: 0, right: 0)

        viewModel.clearIfSelectedAtm()
    }

}



