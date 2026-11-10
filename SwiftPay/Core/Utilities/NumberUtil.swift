import Foundation

func isValidNumber(_ input: String) -> Bool {
    input.range(
        of: #"^[0-9]+(?:\.[0-9]+)?$"#,
        options: .regularExpression
    ) != nil
}
