import XCTest

final class MoviesNativeChecks: XCTestCase {
    let app = XCUIApplication(bundleIdentifier: "com.example.movies")
    func element(_ id: String) -> XCUIElement { app.descendants(matching: .any).matching(identifier: id).firstMatch }
    func tap(_ id: String, file: StaticString = #filePath, line: UInt = #line) {
        for _ in 0..<18 {
            let target = element(id)
            if target.exists && target.isHittable { target.tap(); return }
            app.swipeUp()
        }
        XCTFail("Unreachable action: \(id)", file: file, line: line)
    }
    func waitSaved(_ suffix: String, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertTrue(element("movies.testing.persisted.\(suffix)").waitForExistence(timeout: 10), "Missing committed state \(suffix)", file: file, line: line)
    }
    func screenshot(_ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot()); attachment.name = name; attachment.lifetime = .keepAlways; add(attachment)
        let tree = XCTAttachment(string: app.debugDescription); tree.name = "\(name)-native-accessibility"; tree.lifetime = .keepAlways; add(tree)
    }
    override func setUpWithError() throws { continueAfterFailure = false; XCUIDevice.shared.orientation = .portrait; app.launch() }
    override func tearDownWithError() throws { if let run = testRun, run.hasSucceeded == false { screenshot("failure-\(name)") }; XCUIDevice.shared.orientation = .portrait }
    func addNorthbound() {
        tap("movies.shell.tab.home"); tap("movies.home.carousel.featured.movie.900001.open")
        tap("movies.home.movie.900001.favorite"); waitSaved("900001")
    }
    func testN1DurableAddRemovalAndUndo() {
        waitSaved("empty"); addNorthbound()
        app.terminate(); app.launch(); waitSaved("900001"); tap("movies.shell.tab.library")
        XCTAssertTrue(element("movies.library.favorites.movie.900001.open").waitForExistence(timeout: 5))
        tap("movies.library.favorites.movie.900001.open")
        let favorite = element("movies.library.movie.900001.favorite")
        for _ in 0..<8 { if favorite.exists { break }; app.swipeUp() }
        XCTAssertTrue(favorite.label.contains("Remove"))
        tap("movies.library.movie.900001.back"); tap("movies.library.favorites.movie.900001.remove"); waitSaved("empty")
        let offer = element("movies.shell.undo.movie.900001.restore")
        XCTAssertTrue(offer.exists)
        expectation(for: NSPredicate(format: "exists == false"), evaluatedWith: offer); waitForExpectations(timeout: 7)
        app.terminate(); app.launch(); waitSaved("empty"); tap("movies.shell.tab.library")
        XCTAssertFalse(element("movies.library.favorites.movie.900001.open").exists)
        addNorthbound(); tap("movies.shell.tab.library"); tap("movies.library.favorites.movie.900001.remove"); waitSaved("empty")
        tap("movies.shell.undo.movie.900001.restore"); waitSaved("900001")
        app.terminate(); app.launch(); waitSaved("900001"); tap("movies.shell.tab.library")
        XCTAssertEqual(app.descendants(matching: .any).matching(identifier: "movies.library.favorites.movie.900001.open").count, 1)
        screenshot("N1-library-restored")
    }
    func testN2RealBackgroundEndsUndo() {
        waitSaved("900001"); tap("movies.shell.tab.library"); tap("movies.library.favorites.movie.900001.remove"); waitSaved("empty")
        tap("movies.shell.tab.search"); XCTAssertTrue(element("movies.shell.undo.movie.900001.restore").exists)
        let start = Date(); XCUIDevice.shared.press(.home); app.activate()
        XCTAssertLessThan(Date().timeIntervalSince(start), 5, "Resume must precede natural offer expiry")
        XCTAssertFalse(element("movies.shell.undo.movie.900001.restore").exists); waitSaved("empty")
        screenshot("N2-real-background-resume")
    }
    func testN4KeyboardRotationAndNativeActions() {
        tap("movies.shell.tab.search"); tap("movies.search.query.input"); app.typeText("Northbound")
        XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 5)); screenshot("N4-search-keyboard")
        XCUIDevice.shared.orientation = .landscapeLeft; screenshot("N4-landscape-keyboard")
        for branch in ["home", "browse", "search", "library"] { let tab = element("movies.shell.tab.\(branch)"); XCTAssertTrue(tab.exists); XCTAssertTrue(tab.isHittable); XCTAssertTrue(tab.isEnabled); XCTAssertGreaterThanOrEqual(tab.frame.width, 48); XCTAssertGreaterThanOrEqual(tab.frame.height, 48) }
        tap("movies.shell.tab.home"); XCUIDevice.shared.orientation = .portrait
        tap("movies.home.carousel.featured.movie.900001.open")
        let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.01, dy: 0.5)); let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.85, dy: 0.5)); start.press(forDuration: 0.1, thenDragTo: end)
        XCTAssertTrue(element("movies.home.screen").waitForExistence(timeout: 5)); screenshot("N4-native-back")
    }
    func testN4LargestText() {
        screenshot("N4-largest-portrait"); XCUIDevice.shared.orientation = .landscapeLeft
        tap("movies.shell.tab.library"); screenshot("N4-largest-landscape-library")
        for branch in ["home", "browse", "search", "library"] { XCTAssertTrue(element("movies.shell.tab.\(branch)").isHittable) }
    }
}
