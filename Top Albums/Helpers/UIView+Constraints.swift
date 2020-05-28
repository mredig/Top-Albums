//
//  UIView+Constraints.swift
//  Top Albums
//
//  Created by Michael Redig on 5/21/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import UIKit

extension UIView {
	struct SafeAreaToggle {
		let top: Bool
		let bottom: Bool
		let leading: Bool
		let trailing: Bool
	}

	func constrain(subview: UIView, inset: UIEdgeInsets = .zero, safeArea: SafeAreaToggle = false) {
		guard subview.isDescendant(of: self) else {
			print("Need to add subview: \(subview) to parent: \(self) first.")
			return
		}

		subview.translatesAutoresizingMaskIntoConstraints = false

		let topAnchor = safeArea.top ? self.safeAreaLayoutGuide.topAnchor : self.topAnchor
		let bottomAnchor = safeArea.bottom ? self.safeAreaLayoutGuide.bottomAnchor : self.bottomAnchor
		let leadingAnchor = safeArea.leading ? self.safeAreaLayoutGuide.leadingAnchor : self.leadingAnchor
		let trailingAnchor = safeArea.trailing ? self.safeAreaLayoutGuide.trailingAnchor : self.trailingAnchor

		NSLayoutConstraint.activate([
			subview.topAnchor.constraint(equalTo: topAnchor, constant: inset.top),
			subview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset.leading),
			bottomAnchor.constraint(equalTo: subview.bottomAnchor, constant: inset.bottom),
			trailingAnchor.constraint(equalTo: subview.trailingAnchor, constant: inset.trailing),
		])
	}
}

extension UIView.SafeAreaToggle: ExpressibleByBooleanLiteral {
	init(uniform: Bool) {
		self.init(horizontal: uniform, vertical: uniform)
	}

	init(horizontal: Bool, vertical: Bool) {
		self.top = vertical
		self.bottom = vertical
		self.leading = horizontal
		self.trailing = horizontal
	}

	public init(booleanLiteral: Bool) {
		self.init(uniform: booleanLiteral)
	}
}

/// Add semantic support for modularity between right to left orientations
extension UIEdgeInsets: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral {

	var leading: CGFloat {
		get { left }
		set { left = newValue }
	}

	var trailing: CGFloat {
		get { right }
		set { right = newValue }
	}

	init(uniform: CGFloat = 0) {
		self.init(top: uniform, left: uniform, bottom: uniform, right: uniform)
	}

	init(horizontal: CGFloat = 0, vertical: CGFloat = 0) {
		self.init(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
	}

	init(top: CGFloat = 0, leading: CGFloat = 0, bottom: CGFloat = 0, trailing: CGFloat = 0) {
		self.init(top: top, left: leading, bottom: bottom, right: trailing)
	}

	public init(floatLiteral value: Double) {
		self.init(uniform: CGFloat(value))
	}

	public init(integerLiteral value: Int) {
		self.init(uniform: CGFloat(value))
	}
}

extension UILayoutPriority: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral {
	public init(floatLiteral value: FloatLiteralType) {
		self.init(Float(value))
	}

	public init(integerLiteral value: IntegerLiteralType) {
		self.init(Float(value))
	}
}
