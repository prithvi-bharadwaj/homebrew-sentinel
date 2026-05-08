import XCTest

final class SentinelTests: XCTestCase {
    func testInfoPlistDeclaresMenuBarOnlySonomaApp() {
        let bundle = Bundle.main

        XCTAssertEqual(bundle.bundleIdentifier, "org.localhost.sentinel")
        XCTAssertEqual(bundle.object(forInfoDictionaryKey: "LSUIElement") as? Bool, true)
        XCTAssertEqual(bundle.object(forInfoDictionaryKey: "LSMinimumSystemVersion") as? String, "14.0")
    }
}
