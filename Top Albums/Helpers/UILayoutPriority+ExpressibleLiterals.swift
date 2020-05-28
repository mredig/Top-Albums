//
//  UILayoutPriority+ExpressibleLiterals.swift
//  Top Albums
//
//  Created by Michael Redig on 5/27/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import UIKit

extension UILayoutPriority: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral {
	public init(floatLiteral value: FloatLiteralType) {
		self.init(Float(value))
	}

	public init(integerLiteral value: IntegerLiteralType) {
		self.init(Float(value))
	}
}
