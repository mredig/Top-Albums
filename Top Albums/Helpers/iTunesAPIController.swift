//
//  iTunesAPI.swift
//  Top Albums
//
//  Created by Michael Redig on 5/6/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import Foundation
import NetworkHandler

class iTunesAPIController {
	private let networkHandler = NetworkHandler.default

	var mediaSearch = MediaType.appleMusic(type: .topAlbums)
	var allowExplicitResults = false
	var maxResults = 100

	private var currentResultOperation: URLSessionDataTask?

	init() {}

	func generateUrl() -> URL {
		guard let baseURL = URL(string: "https://rss.itunes.apple.com/api/v1/us/") else { fatalError("Base URL is broken! \(#file): \(#line)")}

		let feedType: String
		switch mediaSearch {
		case .appleMusic(type: let type):
			feedType = type.rawValue
		case .iTunesMusic(type: let type):
			feedType = type.rawValue
		}

		return baseURL
			.appendingPathComponent(MediaTypeViewModel(mediaType: mediaSearch).urlComponent)
			.appendingPathComponent(feedType)
			.appendingPathComponent("all")
			.appendingPathComponent("\(maxResults)")
			.appendingPathComponent(allowExplicitResults ? "explicit" : "non-explicit")
			.appendingPathExtension("json")
	}

	func fetchResults(completion: @escaping (Result<[MusicResult], NetworkError>) -> Void) {
		currentResultOperation?.cancel()
		let request = generateUrl().request

		currentResultOperation = networkHandler.transferMahCodableDatas(with: request) { (result: Result<[String: MusicResults], NetworkError>) in
			switch result {
			case .success(let resultsDict):
				guard let results = resultsDict["feed"] else {
					completion(.failure(NetworkError.dataWasNull))
					print("iTunes has changed their results feed format.")
					return
				}
				completion(.success(results.results))
			case .failure(let error):
				completion(.failure(error))
			}
		}
	}
}

extension iTunesAPIController: ImageLoader {
	func fetchImage(for musicResultVM: MusicResultViewModel, attemptHighRes: Bool = false, completion: @escaping (Result<Data, NetworkError>) -> Void) -> ImageLoadOperation? {
		let request: NetworkRequest
		if attemptHighRes {
			request = musicResultVM.highResArtworkURL.request
		} else {
			request = musicResultVM.normalArtworkURL.request
		}
		return networkHandler.transferMahDatas(with: request, usingCache: true, completion: completion)
	}
}
