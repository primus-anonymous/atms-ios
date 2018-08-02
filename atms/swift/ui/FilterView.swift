import UIKit


class FilterView: UIView {
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var rootView: UIView!
    
    @IBOutlet weak var filterQuery: UITextField!
    @IBOutlet weak var btnDone: UIButton!
    
    weak var delegate: FilterViewDelegate?
    
    @IBAction func doneTapped(_ sender: Any) {
        delegate?.doneTapped(view: self)
    }
    
    @IBAction func filterValueChanged(_ sender: Any) {
    
        if let textField = sender as? UITextField {
            delegate?.filterValueChanged(view: self, value: textField.text ?? "")
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        loadXib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        loadXib()
    }
    
    
    private func loadXib() {
        Bundle.main.loadNibNamed("FIlterView", owner: self, options: nil)
        
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        rootView.layer.cornerRadius = 8.0
        
        rootView.layer.shadowRadius = 2
        rootView.layer.shadowColor = UIColor.black.cgColor
        rootView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        rootView.layer.shadowOpacity = 0.33
        
        filterQuery.placeholder = "filter".localized
        btnDone.setTitle("done".localized, for: .normal)
        
        filterQuery.delegate = self

    }
}

extension FilterView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.doneTapped(view: self)
        return true
    }
    
}

protocol FilterViewDelegate: class {
    
    func doneTapped(view: FilterView)
    
    func filterValueChanged(view: FilterView, value: String)

}
