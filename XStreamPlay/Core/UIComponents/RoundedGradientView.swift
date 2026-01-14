//
//  RoundedGradientView.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 13/01/26.
//

import UIKit

@IBDesignable
final class RoundedGradientView: UIView {

    // MARK: - Corner Configuration

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet { setNeedsLayout() }
    }

    @IBInspectable var isCircle: Bool = false {
        didSet { setNeedsLayout() }
    }

    @IBInspectable var topLeft: Bool = false
    @IBInspectable var topRight: Bool = false
    @IBInspectable var bottomLeft: Bool = false
    @IBInspectable var bottomRight: Bool = false

    // MARK: - Gradient Configuration

    @IBInspectable var startColor: UIColor = .clear {
        didSet { updateGradient() }
    }

    @IBInspectable var endColor: UIColor = .clear {
        didSet { updateGradient() }
    }

    @IBInspectable var startX: CGFloat = 0 {
        didSet { updateGradient() }
    }

    @IBInspectable var startY: CGFloat = 0 {
        didSet { updateGradient() }
    }

    @IBInspectable var endX: CGFloat = 1 {
        didSet { updateGradient() }
    }

    @IBInspectable var endY: CGFloat = 1 {
        didSet { updateGradient() }
    }

    private let gradientLayer = CAGradientLayer()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        commonInit()
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        applyCorners()
        updateGradient()
    }

    // MARK: - Setup

    private func commonInit() {
        layer.insertSublayer(gradientLayer, at: 0)
    }

    // MARK: - Corner Handling

    private func applyCorners() {
        if isCircle {
            layer.cornerRadius = bounds.height / 2
            layer.masksToBounds = true
            return
        }

        var maskedCorners: CACornerMask = []

        if topLeft { maskedCorners.insert(.layerMinXMinYCorner) }
        if topRight { maskedCorners.insert(.layerMaxXMinYCorner) }
        if bottomLeft { maskedCorners.insert(.layerMinXMaxYCorner) }
        if bottomRight { maskedCorners.insert(.layerMaxXMaxYCorner) }

        layer.cornerRadius = cornerRadius
        layer.maskedCorners = maskedCorners.isEmpty
            ? [.layerMinXMinYCorner, .layerMaxXMinYCorner,
               .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            : maskedCorners

        layer.masksToBounds = true
    }

    // MARK: - Gradient Handling

    private func updateGradient() {
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: startX, y: startY)
        gradientLayer.endPoint = CGPoint(x: endX, y: endY)
    }
}

