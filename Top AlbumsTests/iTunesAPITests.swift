//
//  iTunesAPITests.swift
//  Top AlbumsTests
//
//  Created by Michael Redig on 5/6/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import XCTest
@testable import Top_Albums
import NetworkHandler

class iTunesAPITests: XCTestCase {

	var serverSessionSimulator: NetworkMockingSession {
		ServerSideSimulator().serverSessionSimulator
	}

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

	func lilTjayMusicResultVM() -> MusicResultViewModel? {
		guard let sourceData = top10AppleMusicAlbumsNE else { return nil }
		let musicResultsDict = try? JSONDecoder().decode([String: MusicResults].self, from: sourceData)
		guard let musicResults = musicResultsDict?["feed"] else { return nil }

		return MusicResultViewModel(musicResult: musicResults.results[0])
	}

	func lilTjaySongResultVM() -> SongResultViewModel? {
		guard let sourceData = sampleSongPreviewsJSON else { return nil }
		let songResults = try? JSONDecoder().decode(SongResults.self, from: sourceData)
		guard let first = songResults?.results.first else { return nil }

		return SongResultViewModel(songResult: first)
	}

	func testURLGeneration() {
		let itunesController = iTunesAPIController(baseURLString: "https://rss.itunes.apple.com/api/v1/us/")
		itunesController.allowExplicitResults = false

		itunesController.mediaSearch = .appleMusic(type: .topAlbums)
		XCTAssertEqual("https://rss.itunes.apple.com/api/v1/us/apple-music/top-albums/all/100/non-explicit.json", itunesController.generateUrl().absoluteString)
		itunesController.mediaSearch = .appleMusic(type: .comingSoon)
		XCTAssertEqual("https://rss.itunes.apple.com/api/v1/us/apple-music/coming-soon/all/100/non-explicit.json", itunesController.generateUrl().absoluteString)
		itunesController.mediaSearch = .appleMusic(type: .hotTracks)
		XCTAssertEqual("https://rss.itunes.apple.com/api/v1/us/apple-music/hot-tracks/all/100/non-explicit.json", itunesController.generateUrl().absoluteString)
		itunesController.mediaSearch = .appleMusic(type: .newReleases)
		XCTAssertEqual("https://rss.itunes.apple.com/api/v1/us/apple-music/new-releases/all/100/non-explicit.json", itunesController.generateUrl().absoluteString)
		itunesController.mediaSearch = .appleMusic(type: .topSongs)
		XCTAssertEqual("https://rss.itunes.apple.com/api/v1/us/apple-music/top-songs/all/100/non-explicit.json", itunesController.generateUrl().absoluteString)

		itunesController.allowExplicitResults = true
		itunesController.mediaSearch = .appleMusic(type: .topAlbums)
		XCTAssertEqual("https://rss.itunes.apple.com/api/v1/us/apple-music/top-albums/all/100/explicit.json", itunesController.generateUrl().absoluteString)

		itunesController.allowExplicitResults = false
		itunesController.mediaSearch = .iTunesMusic(type: .hotTracks)
		XCTAssertEqual("https://rss.itunes.apple.com/api/v1/us/itunes-music/hot-tracks/all/100/non-explicit.json", itunesController.generateUrl().absoluteString)
		itunesController.mediaSearch = .iTunesMusic(type: .newMusic)
		XCTAssertEqual("https://rss.itunes.apple.com/api/v1/us/itunes-music/new-music/all/100/non-explicit.json", itunesController.generateUrl().absoluteString)
		itunesController.mediaSearch = .iTunesMusic(type: .recentReleases)
		XCTAssertEqual("https://rss.itunes.apple.com/api/v1/us/itunes-music/recent-releases/all/100/non-explicit.json", itunesController.generateUrl().absoluteString)
		itunesController.mediaSearch = .iTunesMusic(type: .topAlbums)
		XCTAssertEqual("https://rss.itunes.apple.com/api/v1/us/itunes-music/top-albums/all/100/non-explicit.json", itunesController.generateUrl().absoluteString)
		itunesController.mediaSearch = .iTunesMusic(type: .topSongs)
		XCTAssertEqual("https://rss.itunes.apple.com/api/v1/us/itunes-music/top-songs/all/100/non-explicit.json", itunesController.generateUrl().absoluteString)
	}

	/// Tests that a properly formed url will provide a correctly decoded payload using mocking.
	///
	/// See ServerSideSimulator for URL verification (nothing will be returned if a URL is incorrect)
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
		XCTAssertEqual("State of Emergency", firstResultVM.name)
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

	/// Tests that image fetching works, again using ServerSideSimualtor
	func testImageFetching() {
		guard let lilTjayResultVM = lilTjayMusicResultVM() else {
			XCTFail("Problem getting json object")
			return
		}

		let apiController = iTunesAPIController(baseURLString: "https://rss.itunes.apple.com/api/v1/us/", session: serverSessionSimulator)

		let imageLoader: ImageLoader = apiController

		let thumbnailExpectation = expectation(description: "image1Exp")
		let fullSizeExpectation = expectation(description: "image2Exp")

		var thumbnailResult: Result<Data, NetworkError>?
		var fullSizeResult: Result<Data, NetworkError>?

		_ = imageLoader.fetchImage(for: lilTjayResultVM, attemptHighRes: false) { result in
			thumbnailResult = result
			thumbnailExpectation.fulfill()
		}

		_ = imageLoader.fetchImage(for: lilTjayResultVM, attemptHighRes: true) { result in
			fullSizeResult = result
			fullSizeExpectation.fulfill()
		}

		wait(for: [thumbnailExpectation, fullSizeExpectation], timeout: 2)

		var thumbnailData: Data?
		var fullSizeData: Data?

		XCTAssertNoThrow(thumbnailData = try thumbnailResult?.get())
		XCTAssertNoThrow(fullSizeData = try fullSizeResult?.get())

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

	func testSongPreviewsFetch() throws {
		let myExpectation = expectation(description: "netload")
		guard let lilTjayVM = lilTjayMusicResultVM() else { return }

		let apiController = iTunesAPIController(baseURLString: "https://rss.itunes.apple.com/api/v1/us/", session: serverSessionSimulator)

		var theResult: Result<[SongResult], NetworkError>?
		apiController.fetchPreviewList(for: lilTjayVM) { result in
			theResult = result
			myExpectation.fulfill()
		}
		wait(for: [myExpectation], timeout: 10)

		XCTAssertNoThrow(try theResult?.get())

		let allResults = try theResult?.get()
		guard let firstSong = allResults?.first else {
			XCTFail("No song")
			return
		}

		let songVM = SongResultViewModel(songResult: firstSong)
		XCTAssertEqual("Lil Tjay", songVM.artistName)
		XCTAssertEqual("State of Emergency", songVM.collectionName)
		XCTAssertEqual("Ice Cold", songVM.trackName)
		XCTAssertEqual("1. Ice Cold", songVM.trackNameWithNumber)
		XCTAssertEqual("$1.29", songVM.price)
		XCTAssertEqual(1, songVM.trackNumber)
	}

	func testSongPreviewFetch() throws {
		let myExpectation = expectation(description: "netload")
		guard let lilTjayVM = lilTjaySongResultVM() else { return }

		let apiController = iTunesAPIController(baseURLString: "https://rss.itunes.apple.com/api/v1/us/", session: serverSessionSimulator)

		var theResult: Result<Data, NetworkError>?
		apiController.fetchPreview(for: lilTjayVM) { result in
			theResult = result
			myExpectation.fulfill()
		}
		wait(for: [myExpectation], timeout: 10)

		XCTAssertNoThrow(try theResult?.get())

		let bundle = Bundle(for: Self.self)
		guard let expectedSamplePreviewURL = bundle.url(forResource: "samplePreview", withExtension: "m4a") else {
			XCTFail("Preview resources not found in bundle")
			return
		}

		let expectedSamplePreview = try Data(contentsOf: expectedSamplePreviewURL)

		XCTAssertEqual(expectedSamplePreview, try theResult?.get())
	}

	/// Tests that a bad URL is handled correctly.
	func testBadURL() {
		let myExpectation = expectation(description: "netload")

		let apiController = iTunesAPIController(baseURLString: "https://badurl.com/api/v1/", session: serverSessionSimulator)

		var theResult: Result<[MusicResult], NetworkError>?

		apiController.fetchResults { result in
			theResult = result
			myExpectation.fulfill()
		}
		wait(for: [myExpectation], timeout: 2)

		XCTAssertThrowsError(try theResult?.get(), "Error not thrown when one was expected") { error in
			XCTAssertEqual(error as? NetworkError, NetworkError.httpNon200StatusCode(code: 404, data: nil))
		}
	}

	/// Tests that bad data is handled correctly.
	func testBadData() {
		let myExpectation = expectation(description: "netload")

		let mockSession = NetworkMockingSession(mockData: badData, mockError: nil)

		let apiController = iTunesAPIController(baseURLString: "https://rss.itunes.apple.com/api/v1/us/", session: mockSession)

		var theResult: Result<[MusicResult], NetworkError>?

		apiController.mediaSearch = .appleMusic(type: .topAlbums)
		apiController.maxResults = 10
		apiController.fetchResults { result in
			theResult = result

			myExpectation.fulfill()
		}
		wait(for: [myExpectation], timeout: 2)

		XCTAssertThrowsError(try theResult?.get(), "Error not thrown when one was expected") { error in
			XCTAssertEqual(error as? NetworkError, NetworkError.dataWasNull)
		}
	}
}
