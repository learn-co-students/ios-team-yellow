///
/// TypeExtensions.swift
///

extension String {
    var firstWord: String {
        return components(separatedBy: " ").first ?? ""
    }
}

func += <K, V> (left: [K : V], right: [K : V]) -> [K:V] {
    var leftCopy = left
    for (k, v) in right {
        leftCopy[k] = v
    }
    return leftCopy
}
