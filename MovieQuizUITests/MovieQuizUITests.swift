import XCTest

final class MovieQuizUITests: XCTestCase {

    // swiftlint:disable:next implicitly_unwrapped_optional
    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()

        app = XCUIApplication()
        app.launch()

        continueAfterFailure = false
    }

    func testGameFinish() {
        let noButton = app.buttons["No"]
        XCTAssertTrue(noButton.waitForExistence(timeout: 10))

        for _ in 1...10 {
            noButton.tap()
            if !app.alerts["Этот раунд окончен!"].waitForExistence(timeout: 2) {
                _ = app.staticTexts["Index"].waitForExistence(timeout: 2)
            }
        }

        let alert = app.alerts["Этот раунд окончен!"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        XCTAssertTrue(alert.exists)
        XCTAssertEqual(alert.label, "Этот раунд окончен!")
        XCTAssertEqual(alert.buttons.firstMatch.label, "Сыграть ещё раз")
    }

    func testAlertDismiss() {
        let noButton = app.buttons["No"]
        XCTAssertTrue(noButton.waitForExistence(timeout: 10))

        for _ in 1...10 {
            noButton.tap()
            if !app.alerts["Этот раунд окончен!"].waitForExistence(timeout: 2) {
                _ = app.staticTexts["Index"].waitForExistence(timeout: 2)
            }
        }

        let alert = app.alerts["Этот раунд окончен!"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        alert.buttons.firstMatch.tap()

        let indexLabel = app.staticTexts["Index"]
        XCTAssertTrue(indexLabel.waitForExistence(timeout: 5))
        XCTAssertFalse(alert.exists)
        XCTAssertEqual(indexLabel.label, "1/10")
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()

        app.terminate()
        app = nil
    }
    func testYesButton() {
        let yesButton = app.buttons["Yes"]
        XCTAssertTrue(yesButton.waitForExistence(timeout: 10))

        let indexLabel = app.staticTexts["Index"]
        XCTAssertTrue(indexLabel.waitForExistence(timeout: 5))
        XCTAssertEqual(indexLabel.label, "1/10")

        yesButton.tap()

        let secondQuestionPredicate = NSPredicate(format: "label == %@", "2/10")
        expectation(for: secondQuestionPredicate, evaluatedWith: indexLabel)
        waitForExpectations(timeout: 5)

        XCTAssertEqual(indexLabel.label, "2/10")
    }

    func testNoButton() {
        let noButton = app.buttons["No"]
        XCTAssertTrue(noButton.waitForExistence(timeout: 10))

        noButton.tap()

        let secondQuestion = app.staticTexts["Index"]
        XCTAssertTrue(secondQuestion.waitForExistence(timeout: 5))
        XCTAssertEqual(secondQuestion.label, "2/10")
    }
}
