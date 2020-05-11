//
//  TestingSupport.swift
//  Top Albums
//
//  Created by Michael Redig on 5/11/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import Foundation
import UIKit

protocol TypeIdentifiable {
	static var identifier: String { get }
}

extension TypeIdentifiable {
	static var identifier: String {
		String(describing: self)
	}
}

fileprivate extension JSONDecoder {
	func decode<T: Decodable>(_ type: T.Type, from json: String) throws -> T {
		guard let data = json.data(using: .utf8) else {
			throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Could not convert String to utf8 Data"))
		}
		return try decode(T.self, from: data)
	}
}

extension Encodable {
	var jsonString: String? {
		guard let jsonData = try? JSONEncoder().encode(self) else { return nil }
		return String(data: jsonData, encoding: .utf8)
	}
}

extension ProcessInfo {
	func decode<T: TypeIdentifiable & Decodable>(_: T.Type) -> T? {
		guard let envInfo = environment[T.identifier] else { return nil }
		return try? JSONDecoder().decode(T.self, from: envInfo)
	}
}

struct MockBlock: TypeIdentifiable, Codable {
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


class MockBlockPointer: TypeIdentifiable, Codable {

	var location: URL?

	enum CodingKeys: String, CodingKey {
		case location
	}

	var mockBlock: MockBlock?

	init(mockBlock: MockBlock) {
		self.mockBlock = mockBlock
	}

	func save() throws {
		guard let mockBlock = mockBlock else { return }
		guard location == nil else {
			NSLog("There's already a mock block saved")
			return
		}
		let newLocation = URL(fileURLWithPath: NSTemporaryDirectory())
			.appendingPathComponent("mockblock")
			.appendingPathExtension("json")
		location = newLocation

		let json = try JSONEncoder().encode(mockBlock)
		try json.write(to: newLocation)

		let thisJson = try JSONEncoder().encode(self)
		guard let thisJsonStr = String(data: thisJson, encoding: .utf8) else { return }
		print("\nFor env setup:\n\nenv key:\n\(Self.identifier)\nenv value:\n\(thisJsonStr)\n\n")
	}

	func load(cleanup: Bool = true) throws {
		guard let fileLocation = location else { return }
		let json = try Data(contentsOf: fileLocation)

		self.mockBlock = try JSONDecoder().decode(MockBlock.self, from: json)

		//cleanup
		if cleanup {
			try FileManager.default.removeItem(at: fileLocation)
			location = nil
		}
	}
}

extension UIView {
	func setupAccessibilityIdentifier(on viewController: UIViewController, id: String) {
		guard isDescendant(of: viewController.view) else { return }
		accessibilityIdentifier = "\(String(describing: type(of: viewController))).\(id)"
	}
}
