import MapKit


class AtmAnnotation: MKPointAnnotation {
    
    let atmNode: AtmNode
    
    init(atmNode: AtmNode) {
        self.atmNode = atmNode
        super.init()
    }
}
