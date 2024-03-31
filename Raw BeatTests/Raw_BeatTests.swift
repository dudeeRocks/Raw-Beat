//
//  Raw_BeatTests.swift
//  Raw BeatTests
//
//  Created by David Katsman on 31/03/2024.
//

import XCTest
@testable import Raw_Beat

final class Raw_BeatTests: XCTestCase {

    var metronome: Metronome! = nil

    override func setUp() {
        metronome = Metronome()
    }

    override func tearDown() {
        metronome = nil
    }
    
    func testPlay() {
        metronome.play()
        XCTAssertTrue(metronome.isPlaying, "Metronome isn't playing.")
    }
    
    func testStop() {
        if !(metronome.isPlaying) {
            metronome.play()
        }
        metronome.stop()
        XCTAssertFalse(metronome.isPlaying, "Metronome is still playing.")
    }
    
    func testSetTempoNoError() {
        let testValue: Int = 90
        XCTAssertNoThrow(try metronome.setTempo(to: testValue), "Tempo was not set to test value (\(testValue) BPM.")
    }
    
    func testSetTempoWithError() {
        let testValue: Int = 999
        XCTAssertThrowsError(try metronome.setTempo(to: testValue), "No error was thrown when setting tempo to invalid value (\(testValue) BPM).")
    }

}
