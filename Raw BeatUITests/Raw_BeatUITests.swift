//
//  Raw_BeatUITests.swift
//  Raw BeatUITests
//
//  Created by David Katsman on 31/03/2024.
//

import XCTest

final class Raw_BeatUITests: XCTestCase {

    var app: XCUIApplication! = nil
    var tempoTextView: XCUIElement! = nil
    
    private let defaultTempo: Int = 120
    private let expectedMinError: String = "Error: Minimum tempo is 40 BPM."
    private let expectedMaxError: String = "Error: Maximum tempo is 240 BPM."
    private let expectedLongPressHint: String = "Long press tempo to edit"
    private let expectedKeepTappingHint: String = "Keep tapping..."
    private let expectedSoundPickerValue: String = "Sound effect is selected"
    private let expectedTimePickerValue: String = "Six eighth is selected"
    
    // MARK: - Set up and tear down

    override func setUp() {
        app = XCUIApplication()
        tempoTextView = app.staticTexts[ViewIdentifiers.tempoText.rawValue]
        continueAfterFailure = false
    }

    override func tearDown() {
        app = nil
        tempoTextView = nil
    }
    
    // MARK: - Tests

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
    
    func testAccessibilityAudit() throws {
        app.launch()
        try app.performAccessibilityAudit()
    }
    
    func testScroll() {
        app.launch()
        checkTempoTextView()
        
        app.swipeUp()
        
        let testTempo = getCurrentTempo()
        
        XCTAssertGreaterThan(testTempo, defaultTempo, "Scroll did not work.")
    }
    
    func testTempoFieldSubmit() {
        app.launch()
        checkTempoTextView()
        
        tempoTextView.press(forDuration: 0.5)
        typeTempo(160)
        pressSubmitButton()
        
        let testTempo = getCurrentTempo()
        
        XCTAssertGreaterThan(testTempo, defaultTempo, "Scroll did not work.")
    }
    
    func testMinTempoError() {
        app.launch()
        checkTempoTextView()
        
        tempoTextView.press(forDuration: 0.5)
        typeTempo(1)
        pressSubmitButton()
        
        let errorMessage = app.staticTexts[ViewIdentifiers.errorMessage.rawValue]
        XCTAssertTrue(errorMessage.isHittable, "Error message is not visible on screen.")
        
        XCTAssertEqual(errorMessage.label, expectedMinError, "Wrong error message on min tempo.")
    }
    
    func testMaxTempoError() {
        app.launch()
        checkTempoTextView()
        
        tempoTextView.press(forDuration: 0.5)
        typeTempo(999)
        pressSubmitButton()
        
        let errorMessage = app.staticTexts[ViewIdentifiers.errorMessage.rawValue]
        XCTAssertTrue(errorMessage.isHittable, "Error message is not visible on screen.")
        
        XCTAssertEqual(errorMessage.label, expectedMaxError, "Wrong error message on max tempo.")
    }
    
    func testLongPressHint() {
        app.launch()
        checkTempoTextView()
        tempoTextView.doubleTap()
        
        let hint = app.staticTexts[ViewIdentifiers.hint.rawValue]
        XCTAssertTrue(hint.exists, "No hint was shown for long press.")
        XCTAssertEqual(hint.label, expectedLongPressHint, "Wrong long press hint text.")
    }
    
    func testKeepTappingHint() {
        app.launch()
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.75)).doubleTap()
        
        let hint = app.staticTexts[ViewIdentifiers.hint.rawValue]
        XCTAssertTrue(hint.exists, "No hint was shown for 'keep tapping'.")
        XCTAssertEqual(hint.label, expectedKeepTappingHint, "Wrong 'keep tapping' hint text.")
    }
    
    func testTapCalculator() {
        app.launch()
        checkTempoTextView()
        
        let testInterval: TimeInterval = 0.15
        let tapLocation: XCUICoordinate = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.75))
        let numberOfTaps: Int = 8
        
        for _ in 0..<numberOfTaps {
            tapLocation.tap()
            Task {
                try await Task.sleep(for: .seconds(testInterval))
            }
        }
        
        let tempo: Int = getCurrentTempo()
        
        XCTAssertNotEqual(tempo, defaultTempo, "Tap calculator did not work.")
    }
    
    func testSoundPicker() {
        app.launch()
        
        let soundPicker = app.buttons[ViewIdentifiers.soundPicker.rawValue]
        XCTAssertTrue(soundPicker.isHittable, "Couldn't not find Sound Picker button.")
        
        soundPicker.tap()
        
        let offset: CGFloat = 100.0
        let pickerX: CGFloat = soundPicker.frame.midX + offset
        let pickerY: CGFloat = soundPicker.frame.midY
        let screenWidth: CGFloat = app.frame.width
        let screenHeight: CGFloat = app.frame.height
        
        let tapLocation = app.coordinate(withNormalizedOffset: CGVector(dx: pickerX / screenWidth, dy: pickerY / screenHeight))
        let didWaitBeforeSelectingSound: XCTestExpectation = .init(description: "Wait for 1 second before selecting sound.")
        let didWaitBeforeClosing: XCTestExpectation = .init(description: "Wait for 1 second before closing sound picker.")
        
        Task {
            try await Task.sleep(for: .seconds(0.5))
            didWaitBeforeSelectingSound.fulfill()
        }
        
        wait(for: [didWaitBeforeSelectingSound], timeout: 1.0)
        tapLocation.tap()
        
        Task {
            try await Task.sleep(for: .seconds(1.0))
            didWaitBeforeClosing.fulfill()
        }
        
        wait(for: [didWaitBeforeClosing], timeout: 1.0)
        soundPicker.tap()
        
        guard let soundPickerValue = soundPicker.value as? String else {
            XCTFail("Sound Picker value is not a String.")
            return
        }
        
        XCTAssertEqual(soundPickerValue, expectedSoundPickerValue, "Sound picker did not work.")
    }
    
    func testTimePicker() {
        app.launch()
        
        let timePicker = app.buttons[ViewIdentifiers.timePicker.rawValue]
        XCTAssertTrue(timePicker.isHittable, "Couldn't not find time picker button.")
        
        timePicker.tap()
        
        let offset: CGFloat = -100.0
        let pickerX: CGFloat = timePicker.frame.midX + offset
        let pickerY: CGFloat = timePicker.frame.midY
        let screenWidth: CGFloat = app.frame.width
        let screenHeight: CGFloat = app.frame.height
        
        let tapLocation = app.coordinate(withNormalizedOffset: CGVector(dx: pickerX / screenWidth, dy: pickerY / screenHeight))
        let didWaitBeforeSelectingTime: XCTestExpectation = .init(description: "Wait for 1 second before selecting time signature.")
        let didWaitBeforeClosing: XCTestExpectation = .init(description: "Wait for 1 second before closing time signature picker.")
        
        Task {
            try await Task.sleep(for: .seconds(0.5))
            didWaitBeforeSelectingTime.fulfill()
        }
        
        wait(for: [didWaitBeforeSelectingTime], timeout: 1.0)
        tapLocation.tap()
        
        Task {
            try await Task.sleep(for: .seconds(1.0))
            didWaitBeforeClosing.fulfill()
        }
        
        wait(for: [didWaitBeforeClosing], timeout: 1.0)
        timePicker.tap()
        
        guard let timePickerValue = timePicker.value as? String else {
            XCTFail("Time Picker value is not a String.")
            return
        }
        
        XCTAssertEqual(timePickerValue, expectedTimePickerValue, "Time picker did not work.")
    }
    
    // MARK: - Helper Methods
    
    private func checkTempoTextView() {
        XCTAssertTrue(tempoTextView.exists, "Tempo text was not found.")
        XCTAssertNotNil(tempoTextView.value, "Tempo text value cannot be nil.")
    }
    
    private func getCurrentTempo() -> Int {
        guard let tempoTextViewValue = tempoTextView.value as? String else {
            XCTFail("Tempo text is not a String.")
            return 0
        }
        
        guard let string = tempoTextViewValue.split(separator: " ").first else {
            XCTFail("Couldn't retrieve Int from String.")
            return 0
        }
        
        guard let currentTempo = Int(string) else {
            XCTFail("Couldn't convert TempoText String to Int.")
            return 0
        }
        
        return currentTempo
    }
    
    private func typeTempo(_ tempo: Int) {
        let string = String(tempo)
        
        let tempoField = app.textFields[ViewIdentifiers.tempoField.rawValue]
        XCTAssertTrue(tempoField.isHittable, "Couldn't find Tempo Field.")
        tempoField.typeText(string)
    }
    
    private func pressSubmitButton() {
        let submitButton = app.buttons[ViewIdentifiers.submitButton.rawValue]
        XCTAssertTrue(submitButton.exists, "Couldn't find Submit Button.")
        
        submitButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
    }
}
