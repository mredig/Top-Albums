//
//  NSLayoutConstraint+Priority.swift
//  Top Albums
//
//  Created by Michael Redig on 5/27/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {
	func withPriority(_ value: UILayoutPriority) -> NSLayoutConstraint {
		self.priority = value
		return self
	}
}
