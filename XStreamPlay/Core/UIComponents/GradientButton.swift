//
//  GradientButton.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 16/01/26.
//

import UIKit

@IBDesignable
class GradientButton: UIButton {

    @IBInspectable var startColor: UIColor = .clear { didSet { updateGradient() } }
    @IBInspectable var endColor: UIColor = .clear { didSet { updateGradient() } }
    @IBInspectable var startX: CGFloat = 0.0 { didSet { updateGradient() } }
    @IBInspectable var startY: CGFloat = 0.5 { didSet { updateGradient() } }
    @IBInspectable var endX: CGFloat = 1.0 { didSet { updateGradient() } }
    @IBInspectable var endY: CGFloat = 0.5 { didSet { updateGradient() } }
    @IBInspectable var cornerRadiusValue: CGFloat = 0 { didSet { updateGradient() } }

    private let gradientLayer = CAGradientLayer()

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = cornerRadiusValue
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        updateGradient()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        layer.insertSublayer(gradientLayer, at: 0)
        updateGradient()
    }

    private func updateGradient() {
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: startX, y: startY)
        gradientLayer.endPoint   = CGPoint(x: endX, y: endY)
        gradientLayer.cornerRadius = cornerRadiusValue
        setNeedsLayout()
    }
}
