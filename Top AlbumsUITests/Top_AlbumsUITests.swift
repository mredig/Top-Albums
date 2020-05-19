//
//  Top_AlbumsUITests.swift
//  Top AlbumsUITests
//
//  Created by Michael Redig on 5/9/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import XCTest

/// In the current iteration, mocking isn't working on these UI tests if tested on a real device due to sandboxing
/// constraints. (the source mocked data resides in the UITest sandbox and the app doesn't get access to that.
class Top_AlbumsUITests: XCTestCase {

	override func setUp() {
		continueAfterFailure = false
	}

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

	func getProgress(on progressView: XCUIElement) -> Double? {
		guard var str = progressView.value as? String else { return nil }
		str.removeLast()
		return Double(str)
	}

	/// Configure mocking for UI testing
	func loadMockBlock() -> MockBlock {
		var mockBlock = MockBlock()

		let urls = [
			URL(string: "https://rss.itunes.apple.com/api/v1/us/apple-music/top-albums/all/100/non-explicit.json"),
			URL(string: "https://rss.itunes.apple.com/api/v1/us/itunes-music/hot-tracks/all/100/explicit.json"),
			URL(string: "https://rss.itunes.apple.com/api/v1/us/apple-music/top-albums/all/100/explicit.json"),
			URL(string: "https://rss.itunes.apple.com/api/v1/us/apple-music/coming-soon/all/100/non-explicit.json"),
			URL(string: "https://is5-ssl.mzstatic.com/image/thumb/Music123/v4/e8/cb/4a/e8cb4a95-7b2b-d490-0ff6-519e77129381/886448462880.jpg/200x200bb.png"),
			URL(string: "https://is5-ssl.mzstatic.com/image/thumb/Music123/v4/e8/cb/4a/e8cb4a95-7b2b-d490-0ff6-519e77129381/886448462880.jpg/1024x1024bb.png"),
			URL(string: "https://itunes.apple.com/lookup?id=1511995770&entity=song"),
			URL(string: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview113/v4/2b/b0/3e/2bb03ea0-ac15-f265-633c-9acf88f71928/mzaf_746631026398828737.plus.aac.p.m4a")
			].compactMap { $0 }
		let datas = [
			top10AppleMusicAlbumsNE,
			top10iTunesHotTracksE,
			top10AppleMusicAlbumsE,
			top10AppleMusicComingSoonNE,
			Self.fileData(for: "sampleImage", withExtension: "png"),
			Self.fileData(for: "sampleImageLarge", withExtension: "png"),
			sampleSongPreviewsJSON,
			Self.fileData(for: "samplePreview", withExtension: "m4a")
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

	/// Test that the initial state of the app is as expected
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

	/// Test that the detail VC shows expected data
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

		let previewButton = app.cells["SongCell.Ice Cold"]
		waitForExists(element: previewButton)
		XCTAssertTrue(previewButton.exists)
		previewButton.tap()

		let progressView = previewButton.progressIndicators["SongProgressView"]
		waitForExists(element: progressView)

		// confirm there's forward progress on playback
		var progress = 0.0

		if let checkProgress = getProgress(on: progressView) {
			XCTAssertGreaterThan(checkProgress, progress)
			progress = checkProgress
		}

		if let checkProgress = getProgress(on: progressView) {
			XCTAssertGreaterThan(checkProgress, progress)
			progress = checkProgress
		}

		let itunesButton = app.buttons["ResultDetailViewController.iTunesStoreButton"]
		waitForHittable(element: itunesButton)
		itunesButton.tap()
	}

	/// Test using the filter selection to choose a different feed
	func testAlternateSearch() throws {
		let app = try launchApp()

		let optionsButton = app.navigationBars/*@START_MENU_TOKEN@*/.buttons["ResultsViewController.MoreOptionsButton"]/*[[".buttons[\"ellipsis\"]",".buttons[\"ResultsViewController.MoreOptionsButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
		waitForHittable(element: optionsButton)
		XCTAssertTrue(optionsButton.exists)
		optionsButton.tap()

		let picker = app.pickers["FiltersViewController.OptionPicker"]
		waitForHittable(element: picker)
		XCTAssertTrue(picker.exists)

		let iTunesServiceButton = app
			.segmentedControls["FiltersViewController.ServiceSelector"]
			.buttons["iTunes"]

		waitForHittable(element: iTunesServiceButton)
		XCTAssertTrue(iTunesServiceButton.exists)
		iTunesServiceButton.tap()


		let list = picker.pickerWheels.element(boundBy: 0)

		list.adjust(toPickerWheelValue: "Hot Tracks")

		XCTAssertTrue(list.value as? String == "Hot Tracks")

		let explicitButton = app.switches["FiltersViewController.ExplicitnessToggle"]
		waitForHittable(element: explicitButton)
		explicitButton.tap()

		// dismiss popover
		let dismiss = app.otherElements["dismiss popup"]
		waitForHittable(element: dismiss)
		dismiss.tap()

		// confirm everything reflects intended feed
		let titleBar = app.navigationBars["iTunes: Hot Tracks"]
		waitForExists(element: titleBar)
		XCTAssertTrue(titleBar.exists)

		let cell = app.cells["Result Cell"].staticTexts["Stuck with U"]
		waitForExists(element: cell)
		XCTAssertTrue(cell.exists)

		// confirm the settings stick the next time it's used
		waitForHittable(element: optionsButton)
		optionsButton.tap()

		waitForHittable(element: iTunesServiceButton)
		XCTAssertTrue(iTunesServiceButton.exists)
		XCTAssertTrue(iTunesServiceButton.isSelected)

		let hotTracksPicker = app.pickerWheels["Hot Tracks"]
		waitForExists(element: hotTracksPicker)
		XCTAssertTrue(hotTracksPicker.exists)
	}
}
