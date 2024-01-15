import UIKit

class GradientViewUIKit: UIView {

    private let gradientLayer = CAGradientLayer()
    private let centerLabel = UILabel()
    private var text: String = "Hello world"

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
        setupLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(text: String) {
        self.text = text
        centerLabel.text = text
    }

    private func setupGradient() {
        gradientLayer.colors = [UIColor.blue.cgColor, UIColor.green.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupLabel() {
        centerLabel.text = self.text
        centerLabel.textAlignment = .center
        addSubview(centerLabel)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds

        centerLabel.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 50)
        centerLabel.center = CGPoint(x: bounds.midX, y: bounds.midY)
    }
}
