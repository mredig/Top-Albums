//
//  Array+Optional.swift
//  Top Albums
//
//  Created by Michael Redig on 5/11/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import Foundation

extension Array {
	subscript(_ index: Int, default defaultValue: Element) -> Element {
		guard index < count else { return defaultValue }
		return self[index]
	}
}
