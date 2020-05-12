//
//  ResultViewModelTests.swift
//  Top AlbumsTests
//
//  Created by Michael Redig on 5/6/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import XCTest
@testable import Top_Albums
import NetworkHandler

class ResultViewModelTests: XCTestCase {

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

	/// Tests that the MusicResultViewModel properly reflects the underlying model.
	func testMusicResultViewModel() {
		guard let fullModel = lilTjayVM()?.musicResult else {
			XCTFail("Error loading model")
			return
		}

		let fullVM = MusicResultViewModel(musicResult: fullModel)
		XCTAssertEqual("Lil Tjay", fullVM.artistName)
		XCTAssertEqual("State of Emergency", fullVM.name)
		XCTAssertEqual(1511995770, fullVM.id)
		XCTAssertEqual("May 8, 2020", fullVM.formattedReleaseDate)
		XCTAssertEqual("album", fullVM.kind)
		XCTAssertEqual("℗ 2020 Columbia Records, a Division of Sony Music Entertainment", fullVM.copyright)
		XCTAssertEqual(1436446949, fullVM.artistID)
		XCTAssertEqual(URL(string: "https://music.apple.com/us/artist/lil-tjay/1436446949?app=music"), fullVM.artistURL)
		XCTAssertEqual(URL(string: "https://is5-ssl.mzstatic.com/image/thumb/Music123/v4/e8/cb/4a/e8cb4a95-7b2b-d490-0ff6-519e77129381/886448462880.jpg/200x200bb.png"), fullVM.normalArtworkURL)
		XCTAssertEqual("Hip-Hop/Rap", fullVM.genres.first?.name)
		XCTAssertEqual("Music", fullVM.genres.last?.name)
		XCTAssertEqual(URL(string: "https://music.apple.com/us/album/state-of-emergency/1511995770?app=music"), fullVM.url)

		let partialModel = MusicResult(artistName: nil,
									   id: fullModel.id,
									   releaseDate: nil,
									   name: fullModel.name,
									   kind: fullModel.kind,
									   copyright: nil,
									   artistId: nil,
									   artistUrl: nil,
									   artworkUrl100: fullModel.artworkUrl100,
									   genres: [],
									   url: fullModel.url)

		let partialVM = MusicResultViewModel(musicResult: partialModel)

		XCTAssertNil(partialVM.artistName)
		XCTAssertEqual("State of Emergency", partialVM.name)
		XCTAssertEqual(1511995770, partialVM.id)
		XCTAssertNil(partialVM.formattedReleaseDate)
		XCTAssertEqual("album", partialVM.kind)
		XCTAssertNil(partialVM.copyright)
		XCTAssertNil(partialVM.artistID)
		XCTAssertNil(partialVM.artistURL)
		XCTAssertEqual(URL(string: "https://is5-ssl.mzstatic.com/image/thumb/Music123/v4/e8/cb/4a/e8cb4a95-7b2b-d490-0ff6-519e77129381/886448462880.jpg/200x200bb.png"), partialVM.normalArtworkURL)
		XCTAssertEqual([], partialVM.genres)
		XCTAssertEqual(URL(string: "https://music.apple.com/us/album/state-of-emergency/1511995770?app=music"), partialVM.url)
	}
}
