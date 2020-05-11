//
//  Top_AlbumsUITests.swift
//  Top AlbumsUITests
//
//  Created by Michael Redig on 5/9/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import XCTest

class Top_AlbumsUITests: XCTestCase {

	private static func fileData(for resourceNamed: String, withExtension fileExtension: String) -> Data? {
		let bundle = Bundle(for: Self.self)
		guard let url = bundle.url(forResource: resourceNamed, withExtension: fileExtension) else { return nil }
		return try? Data(contentsOf: url)
	}

	func waitForExists(element: XCUIElement) {
		let exists = NSPredicate(format: "exists == true")
		expectation(for: exists, evaluatedWith: element, handler: nil)
		waitForExpectations(timeout: 5, handler: nil)
	}

	func waitForHittable(element: XCUIElement) {
		let exists = NSPredicate(format: "isHittable == true")
		expectation(for: exists, evaluatedWith: element, handler: nil)
		waitForExpectations(timeout: 5, handler: nil)
	}

	func loadMockBlock() -> MockBlock {
		var mockBlock = MockBlock()

		let urls = [
			URL(string: "https://rss.itunes.apple.com/api/v1/us/apple-music/top-albums/all/100/non-explicit.json"),
			URL(string: "https://rss.itunes.apple.com/api/v1/us/itunes-music/hot-tracks/all/100/explicit.json"),
			URL(string: "https://is5-ssl.mzstatic.com/image/thumb/Music123/v4/e8/cb/4a/e8cb4a95-7b2b-d490-0ff6-519e77129381/886448462880.jpg/200x200bb.png"),
			URL(string: "https://is5-ssl.mzstatic.com/image/thumb/Music123/v4/e8/cb/4a/e8cb4a95-7b2b-d490-0ff6-519e77129381/886448462880.jpg/1024x1024bb.png")
			].compactMap { $0 }
		let datas = [top10AppleMusicAlbumsNE,
					 top10iTunesHotTracksE,
					Self.fileData(for: "sampleImage", withExtension: "png"),
					Self.fileData(for: "sampleImageLarge", withExtension: "png")
		]

		zip(urls, datas).forEach {
			mockBlock.setResource(for: URLRequest(url: $0.0), resource: $0.1)
		}

		return mockBlock
	}

	func launchApp() throws -> XCUIApplication {
		let app = XCUIApplication()
		let mockPointer = MockBlockPointer(mockBlock: loadMockBlock())
		try mockPointer.save()
		guard let mockPointerString = mockPointer.jsonString else {
			XCTFail("Error setting up mock data")
			app.launch()
			return app
		}
		app.launchEnvironment = [MockBlockPointer.identifier: mockPointerString]
		app.launch()
		return app
	}

    func testInitialState() throws {
        // UI tests must launch the application that they test.
		let app = try launchApp()

		let titleBar = app.navigationBars["Music: Top Albums"]
		waitForExists(element: titleBar)
		XCTAssertTrue(titleBar.exists)

		let cell = app.cells["Result Cell"].staticTexts["State of Emergency"]
		waitForExists(element: cell)
		XCTAssertTrue(cell.exists)
    }

	func testDetailVC() throws {
		let app = try launchApp()

		let cell = app.cells["Result Cell"].staticTexts["State of Emergency"]
		waitForHittable(element: cell)
		XCTAssertTrue(cell.exists)
		cell.tap()

		let copyrightLabel = app.staticTexts["ResultDetailViewController.CopyrightLabel"]
		waitForExists(element: copyrightLabel)
		XCTAssertTrue(copyrightLabel.exists)

		let titleLabel = app.navigationBars.staticTexts["State of Emergency"]
		XCTAssertTrue(titleLabel.exists)
		let artistLabel = app.staticTexts["Lil Tjay"]
		XCTAssertTrue(artistLabel.exists)

		let genreLabel = app.staticTexts["ResultDetailViewController.GenreLabel"]
		XCTAssertTrue(genreLabel.exists)
		let releaseDateLabel = app.staticTexts["ResultDetailViewController.ReleaseDateLabel"]
		XCTAssertTrue(releaseDateLabel.exists)

		let albumImage = app.images["ResultDetailViewController.AlbumImageView"]
		XCTAssertTrue(albumImage.exists)

		let itunesButton = app.buttons["ResultDetailViewController.iTunesStoreButton"]
		waitForHittable(element: itunesButton)
		itunesButton.tap()
	}
}
