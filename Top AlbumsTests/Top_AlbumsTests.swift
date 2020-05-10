//
//  Top_AlbumsTests.swift
//  Top AlbumsTests
//
//  Created by Michael Redig on 5/6/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import XCTest
@testable import Top_Albums
import NetworkHandler

class Top_AlbumsTests: XCTestCase {

	lazy var serverSessionSimulator: NetworkMockingSession = {
		let session = NetworkMockingSession { request -> (Data?, Int, Error?) in
			guard let data = self.serverTable[request.url] else {
				print("Unrecognized test URL: \(request.url as Any)")
				return (nil, 404, nil)
			}

			return (data, 200, nil)
		}
		return session
	}()

	lazy var serverTable: [URL?: Data?] = [
		URL(string: "https://rss.itunes.apple.com/api/v1/us/apple-music/top-albums/all/10/non-explicit.json"): top10AppleMusicAlbumsNE,
		URL(string: "https://rss.itunes.apple.com/api/v1/us/apple-music/top-albums/all/10/explicit.json"): top10AppleMusicAlbumsE,
		URL(string: "https://rss.itunes.apple.com/api/v1/us/apple-music/coming-soon/all/10/non-explicit.json"): top10AppleMusicComingSoonNE,
		URL(string: "https://is5-ssl.mzstatic.com/image/thumb/Music123/v4/e8/cb/4a/e8cb4a95-7b2b-d490-0ff6-519e77129381/886448462880.jpg/200x200bb.png"): try? Data(contentsOf: sampleImageURL(for: "sampleImage")),
		URL(string: "https://is5-ssl.mzstatic.com/image/thumb/Music123/v4/e8/cb/4a/e8cb4a95-7b2b-d490-0ff6-519e77129381/886448462880.jpg/1024x1024bb.png"): try? Data(contentsOf: sampleImageURL(for: "sampleImageLarge")),
	]

	private func sampleImageURL(for resourceNamed: String) -> URL {
		let bundle = Bundle(for: Self.self)
		guard let url = bundle.url(forResource: resourceNamed, withExtension: "png") else { fatalError("Missing image named: \(resourceNamed)") }
		return url
	}


    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

	func lilTjayVM() -> MusicResultViewModel? {
		guard let sourceData = top10AppleMusicAlbumsNE else {
			return nil
		}
		let musicResultsDict = try? JSONDecoder().decode([String: MusicResults].self, from: sourceData)
		guard let musicResults = musicResultsDict?["feed"] else {
			return nil
		}

		let lilTjayResultVM = MusicResultViewModel(musicResult: musicResults.results[0])
		return lilTjayResultVM
	}

//	func testURLGeneration() {
//		let itunesController = iTunesAPIController()
//		itunesController.allowExplicitResults = false
//
//		itunesController.mediaSearch = .appleMusic(type: .topAlbums)
//		XCTAssertEqual("https://rss.itunes.apple.com/api/v1/us/apple-music/top-albums/all/100/non-explicit.json", itunesController.generateUrl().absoluteString)
//		itunesController.mediaSearch = .appleMusic(type: .comingSoon)
//		XCTAssertEqual("https://rss.itunes.apple.com/api/v1/us/apple-music/coming-soon/all/100/non-explicit.json", itunesController.generateUrl().absoluteString)
//		itunesController.mediaSearch = .appleMusic(type: .hotTracks)
//		XCTAssertEqual("https://rss.itunes.apple.com/api/v1/us/apple-music/hot-tracks/all/100/non-explicit.json", itunesController.generateUrl().absoluteString)
//		itunesController.mediaSearch = .appleMusic(type: .newReleases)
//		XCTAssertEqual("https://rss.itunes.apple.com/api/v1/us/apple-music/new-releases/all/100/non-explicit.json", itunesController.generateUrl().absoluteString)
//		itunesController.mediaSearch = .appleMusic(type: .topSongs)
//		XCTAssertEqual("https://rss.itunes.apple.com/api/v1/us/apple-music/top-songs/all/100/non-explicit.json", itunesController.generateUrl().absoluteString)
//
//		itunesController.allowExplicitResults = true
//		itunesController.mediaSearch = .appleMusic(type: .topAlbums)
//		XCTAssertEqual("https://rss.itunes.apple.com/api/v1/us/apple-music/top-albums/all/100/explicit.json", itunesController.generateUrl().absoluteString)
//
//		itunesController.allowExplicitResults = false
//		itunesController.mediaSearch = .iTunesMusic(type: .hotTracks)
//		XCTAssertEqual("https://rss.itunes.apple.com/api/v1/us/itunes-music/hot-tracks/all/100/non-explicit.json", itunesController.generateUrl().absoluteString)
//		itunesController.mediaSearch = .iTunesMusic(type: .newMusic)
//		XCTAssertEqual("https://rss.itunes.apple.com/api/v1/us/itunes-music/new-music/all/100/non-explicit.json", itunesController.generateUrl().absoluteString)
//		itunesController.mediaSearch = .iTunesMusic(type: .recentReleases)
//		XCTAssertEqual("https://rss.itunes.apple.com/api/v1/us/itunes-music/recent-releases/all/100/non-explicit.json", itunesController.generateUrl().absoluteString)
//		itunesController.mediaSearch = .iTunesMusic(type: .topAlbums)
//		XCTAssertEqual("https://rss.itunes.apple.com/api/v1/us/itunes-music/top-albums/all/100/non-explicit.json", itunesController.generateUrl().absoluteString)
//		itunesController.mediaSearch = .iTunesMusic(type: .topSongs)
//		XCTAssertEqual("https://rss.itunes.apple.com/api/v1/us/itunes-music/top-songs/all/100/non-explicit.json", itunesController.generateUrl().absoluteString)
//	}

	func testFetchTopAlbumResults() {
		let myExpectation = expectation(description: "netload")

		let apiController = iTunesAPIController(baseURLString: "https://rss.itunes.apple.com/api/v1/us/", session: serverSessionSimulator)

		var firstResult: MusicResult?

		apiController.mediaSearch = .appleMusic(type: .topAlbums)
		apiController.maxResults = 10
		apiController.fetchResults { result in
			do {
				let results = try result.get()
				firstResult = results.first
			} catch {
				XCTFail("There was an error mock fetching the data")
			}
			myExpectation.fulfill()
		}
		wait(for: [myExpectation], timeout: 2)
		guard let firstResultUnwrapped = firstResult else {
			XCTFail("First result was invalid")
			return
		}

		let firstResultVM = MusicResultViewModel(musicResult: firstResultUnwrapped)
		XCTAssertEqual("Lil Tjay", firstResultVM.artistName)
		XCTAssertEqual(1511995770, firstResultVM.id)
		XCTAssertEqual("May 8, 2020", firstResultVM.formattedReleaseDate)
		XCTAssertEqual("album", firstResultVM.kind)
		XCTAssertEqual("℗ 2020 Columbia Records, a Division of Sony Music Entertainment", firstResultVM.copyright)
		XCTAssertEqual(1436446949, firstResultVM.artistID)
		XCTAssertEqual(URL(string: "https://music.apple.com/us/artist/lil-tjay/1436446949?app=music"), firstResultVM.artistURL)
		XCTAssertEqual(URL(string: "https://is5-ssl.mzstatic.com/image/thumb/Music123/v4/e8/cb/4a/e8cb4a95-7b2b-d490-0ff6-519e77129381/886448462880.jpg/200x200bb.png"), firstResultVM.normalArtworkURL)
		XCTAssertEqual("Hip-Hop/Rap", firstResultVM.genres.first?.name)
		XCTAssertEqual("Music", firstResultVM.genres.last?.name)
		XCTAssertEqual(URL(string: "https://music.apple.com/us/album/state-of-emergency/1511995770?app=music"), firstResultVM.url)
	}

	func testImageFetching() {
		guard let lilTjayResultVM = lilTjayVM() else {
			XCTFail("Problem getting json object")
			return
		}

		let apiController = iTunesAPIController(baseURLString: "https://rss.itunes.apple.com/api/v1/us/", session: serverSessionSimulator)

		let imageLoader: ImageLoader = apiController

		let thumbnailExpectation = expectation(description: "image1Exp")
		let fullSizeExpectation = expectation(description: "image2Exp")

		var thumbnailData: Data?
		var fullSizeData: Data?

		_ = imageLoader.fetchImage(for: lilTjayResultVM, attemptHighRes: false) { result in
			do {
				thumbnailData = try result.get()
			} catch {
				XCTFail("Thumbnail image fetch broken")
			}
			thumbnailExpectation.fulfill()
		}

		_ = imageLoader.fetchImage(for: lilTjayResultVM, attemptHighRes: true) { result in
			do {
				fullSizeData = try result.get()
			} catch {
				XCTFail("Thumbnail image fetch broken")
			}
			fullSizeExpectation.fulfill()
		}

		wait(for: [thumbnailExpectation, fullSizeExpectation], timeout: 2)

		let bundle = Bundle(for: Self.self)
		guard let thumbURL = bundle.url(forResource: "sampleImage", withExtension: "png"),
			let fullURL = bundle.url(forResource: "sampleImageLarge", withExtension: "png") else {
				XCTFail("Image resources not found in bundle")
				return
		}

		let expectedThumbData = try? Data(contentsOf: thumbURL)
		let expectedFullData = try? Data(contentsOf: fullURL)

		XCTAssertEqual(thumbnailData, expectedThumbData)
		XCTAssertEqual(fullSizeData, expectedFullData)
	}
}
