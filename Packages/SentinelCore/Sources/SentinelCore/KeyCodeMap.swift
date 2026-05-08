/// Bidirectional mapping for the stable subset of US ANSI macOS virtual key codes Sentinel stores.
public enum KeyCodeMap {
    private static let keyToCode: [String: UInt16] = [
        "A": 0, "S": 1, "D": 2, "F": 3, "H": 4, "G": 5, "Z": 6, "X": 7, "C": 8, "V": 9,
        "B": 11, "Q": 12, "W": 13, "E": 14, "R": 15, "Y": 16, "T": 17, "1": 18, "2": 19,
        "3": 20, "4": 21, "6": 22, "5": 23, "=": 24, "9": 25, "7": 26, "-": 27, "8": 28,
        "0": 29, "]": 30, "O": 31, "U": 32, "[": 33, "I": 34, "P": 35, "L": 37, "J": 38,
        "'": 39, "K": 40, ";": 41, "\\": 42, ",": 43, "/": 44, "N": 45, "M": 46, ".": 47,
        "`": 50
    ]

    private static let codeToKey = Dictionary(uniqueKeysWithValues: keyToCode.map { ($0.value, $0.key) })

    /// Returns the virtual key code for a display key.
    public static func keyCode(for key: String) -> UInt16? {
        keyToCode[key.uppercased()]
    }

    /// Returns the display key for a virtual key code.
    public static func key(for keyCode: UInt16) -> String? {
        codeToKey[keyCode]
    }
}
