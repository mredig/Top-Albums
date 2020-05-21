//
//  UIView+Constraints.swift
//  Top Albums
//
//  Created by Michael Redig on 5/21/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import UIKit

extension UIView {
	func constrain(subview: UIView, inset: UIEdgeInsets = .zero) {
		guard subview.isDescendant(of: self) else {
			print("Need to add subview: \(subview) to parent: \(self) first.")
			return
		}

		subview.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			subview.topAnchor.constraint(equalTo: self.topAnchor, constant: inset.top),
			subview.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: inset.leading),
			self.bottomAnchor.constraint(equalTo: subview.bottomAnchor, constant: inset.bottom),
			self.trailingAnchor.constraint(equalTo: subview.trailingAnchor, constant: inset.trailing),
		])
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

	init(top: CGFloat, leading: CGFloat, bottom: CGFloat, trailing: CGFloat) {
		self.init(top: top, left: leading, bottom: bottom, right: trailing)
	}

	public init(floatLiteral value: Double) {
		self.init(uniform: CGFloat(value))
	}

	public init(integerLiteral value: Int) {
		self.init(uniform: CGFloat(value))
	}
}
