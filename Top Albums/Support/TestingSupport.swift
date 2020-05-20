//
//  TestingSupport.swift
//  Top Albums
//
//  Created by Michael Redig on 5/11/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import Foundation
import UIKit

struct MockBlock: Codable {
	private var resources: [MockKey: MockValue] = [:]
	var verifyHeaders: Bool = false

	private struct MockKey: Hashable, Codable {
		let url: URL
		let method: String
	}

	private struct MockValue: Codable {
		let data: Data
		let requestHeaders: [String: String]?
		let responseCode: Int
	}

	init() {}

	mutating func setResource(for request: URLRequest, resource: Data?, httpResponseCode: Int = 200) {
		guard let url = request.url, let method = request.httpMethod else { return }
		let key = MockKey(url: url, method: method)
		guard let resource = resource else {
			resources[key] = nil
			return
		}
		resources[key] = MockValue(data: resource, requestHeaders: request.allHTTPHeaderFields, responseCode: httpResponseCode)
	}

	func resource(for request: URLRequest) -> (data: Data?, responseCode: Int)? {
		guard let url = request.url, let method = request.httpMethod else { return nil }
		let key = MockKey(url: url, method: method)
		guard let resource = resources[key] else { return nil }
		if verifyHeaders && resource.requestHeaders != request.allHTTPHeaderFields {
			return nil
		}
		return (resource.data, resource.responseCode)
	}
}

extension UIView {
	func setupAccessibilityIdentifier(on viewController: UIViewController, id: String) {
		guard isDescendant(of: viewController.view) else { return }
		accessibilityIdentifier = "\(String(describing: type(of: viewController))).\(id)"
	}
}
