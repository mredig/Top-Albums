//
//  ServerSideSimulator.swift
//  Top AlbumsTests
//
//  Created by Michael Redig on 5/9/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import Foundation
import NetworkHandler

class ServerSideSimulator {

	let serverSessionSimulator: NetworkMockingSession = {
		let session = NetworkMockingSession { request -> (Data?, Int, Error?) in
			guard let data = ServerSideSimulator.serverTable[request.url] else {
				print("Unrecognized test URL: \(request.url as Any)")
				return (nil, 404, nil)
			}

			return (data, 200, nil)
		}
		return session
	}()

	private static let serverTable: [URL?: Data?] = [
		URL(string: "https://rss.itunes.apple.com/api/v1/us/apple-music/top-albums/all/10/non-explicit.json"): top10AppleMusicAlbumsNE,
		URL(string: "https://rss.itunes.apple.com/api/v1/us/apple-music/top-albums/all/10/explicit.json"): top10AppleMusicAlbumsE,
		URL(string: "https://rss.itunes.apple.com/api/v1/us/apple-music/coming-soon/all/10/non-explicit.json"): top10AppleMusicComingSoonNE,
		URL(string: "https://is5-ssl.mzstatic.com/image/thumb/Music123/v4/e8/cb/4a/e8cb4a95-7b2b-d490-0ff6-519e77129381/886448462880.jpg/200x200bb.png"): try? Data(contentsOf: sampleImageURL(for: "sampleImage")),
		URL(string: "https://is5-ssl.mzstatic.com/image/thumb/Music123/v4/e8/cb/4a/e8cb4a95-7b2b-d490-0ff6-519e77129381/886448462880.jpg/1024x1024bb.png"): try? Data(contentsOf: sampleImageURL(for: "sampleImageLarge")),
	]

	private static func sampleImageURL(for resourceNamed: String) -> URL {
		let bundle = Bundle(for: Self.self)
		guard let url = bundle.url(forResource: resourceNamed, withExtension: "png") else { fatalError("Missing image named: \(resourceNamed)") }
		return url
	}

}
