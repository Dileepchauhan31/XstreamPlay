//
//  GradientView.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 16/01/26.
//

import UIKit

@IBDesignable
final class GradientView: UIView {

    // MARK: - Gradient Colors
    @IBInspectable var startColor: UIColor = .clear {
        didSet { updateGradient() }
    }

    @IBInspectable var endColor: UIColor = .clear {
        didSet { updateGradient() }
    }

    // MARK: - Gradient Locations (0.0 → 1.0)
    @IBInspectable var startLocation: CGFloat = 0.0 {
        didSet { updateGradient() }
    }

    @IBInspectable var endLocation: CGFloat = 1.0 {
        didSet { updateGradient() }
    }

    // MARK: - Start Point (X, Y Axis Wise)
    @IBInspectable var startPointX: CGFloat = 0.5 {
        didSet { updateGradient() }
    }

    @IBInspectable var startPointY: CGFloat = 0.0 {
        didSet { updateGradient() }
    }

    // MARK: - End Point (X, Y Axis Wise)
    @IBInspectable var endPointX: CGFloat = 0.5 {
        didSet { updateGradient() }
    }

    @IBInspectable var endPointY: CGFloat = 1.0 {
        didSet { updateGradient() }
    }

    // MARK: - Corner Radius
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet { updateCornerRadius() }
    }

    // MARK: - Gradient Layer
    private let gradientLayer = CAGradientLayer()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - Setup
    private func setup() {
        layer.insertSublayer(gradientLayer, at: 0)
        updateGradient()
        updateCornerRadius()
    }

    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        updateCornerRadius()
    }

    // MARK: - Updates
    private func updateGradient() {
        gradientLayer.colors = [
            startColor.cgColor,
            endColor.cgColor
        ]

        gradientLayer.locations = [
            NSNumber(value: Float(startLocation)),
            NSNumber(value: Float(endLocation))
        ]

        // Axis-wise control
        gradientLayer.startPoint = CGPoint(x: startPointX, y: startPointY)
        gradientLayer.endPoint   = CGPoint(x: endPointX, y: endPointY)
    }

    private func updateCornerRadius() {
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = cornerRadius > 0
        gradientLayer.cornerRadius = cornerRadius
    }

    // MARK: - Preset Gradients

    /// Top Black → Bottom Clear (Vertical)
    func setTopBlackToBottomClear() {
        startColor = UIColor.black
        endColor = UIColor.clear

        startPointX = 0.5
        startPointY = 0.0
        endPointX   = 0.5
        endPointY   = 1.0

        startLocation = 0.0
        endLocation   = 1.0
    }

    /// Top Clear → Bottom Black (Vertical)
    func setTopClearToBottomBlack() {
        startColor = UIColor.clear
        endColor = UIColor.black

        startPointX = 0.5
        startPointY = 0.0
        endPointX   = 0.5
        endPointY   = 1.0

        startLocation = 0.0
        endLocation   = 1.0
    }
}
