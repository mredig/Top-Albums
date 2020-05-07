//
//  Optional+Throw.swift
//  Top Albums
//
//  Created by Michael Redig on 5/6/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import Foundation

extension Optional {
	enum UnwrapError<Wrapped>: Error {
		case nilValue(_ wrapped: Wrapped.Type)
	}

	func unwrap() throws -> Wrapped {
		switch self {
		case .some(let value):
			return value
		case .none:
			throw UnwrapError.nilValue(Wrapped.self)
		}
	}
}
