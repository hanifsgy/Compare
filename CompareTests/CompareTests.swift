//
//  CompareTests.swift
//  CompareTests
//
//  Created by Muhammad Hanif Sugiyanto on 03/10/24.
//

import Testing
import DifferenceKit
@testable import Compare
struct CompareTests {
    @Test("CollectionDifference Basic Test")
    func testCollectionDifference() throws {
        let source = [1, 2, 3, 4, 5]
        let target = [1, 3, 4, 6, 5]
        
        let difference = target.difference(from: source)
        assert(difference.insertions.count == 1, "Expected 1 insertion")
        assert(difference.removals.count == 1, "Expected 1 removal")
        if let insertion = difference.insertions.first {
            switch insertion {
            case .insert(let offset, let element, _):
                assert(element == 6, "Expected insertion of 6")
                assert(offset == 3, "Expected insertion at offset 3")
            default:
                assertionFailure("Expected an insertion")
            }
        }
        
        if let removal = difference.removals.first {
            switch removal {
            case .remove(let offset, let element, _):
                assert(element == 2, "Expected removal of 2")
                assert(offset == 1, "Expected removal at offset 1")
            default:
                assertionFailure("Expected a removal")
            }
        }
        // Since apple doesnt have built-in methods to populate
        // We need to doing manual
        // Apply the difference manually and check the result
        var result = source
        // Apply removals first
        for removal in difference.removals.reversed() {
            if case let .remove(offset, _, _) = removal {
                result.remove(at: offset)
            }
        }
        // Then apply insertions
        for insertion in difference.insertions {
            if case let .insert(offset, element, _) = insertion {
                result.insert(element, at: offset)
            }
        }
        assert(result == target, "Applying difference should result in target")
    }
    /// Swift standard CollectionDifference doesn't support sectioned data / multi-dimensional collections
    /// designed to work with one dimensionals collection like an arrays
    ///
    @Test("CollectionDifference with Simulated Sections")
    func testCollectionDifferenceWithSections() throws {
        // Simulate sectioned data using tuples
        let source = [
            (section: 0, items: [1, 2, 3]),
            (section: 1, items: [4, 5])
        ]
        let target = [
            (section: 0, items: [1, 3]),
            (section: 1, items: [4, 5, 6]),
            (section: 2, items: [7])
        ]
        
        // Flatten the data to use CollectionDifference
        let flattenedSource = source.flatMap { $0.items }
        let flattenedTarget = target.flatMap { $0.items }
        
        let difference = flattenedTarget.difference(from: flattenedSource)
        
        // Check the overall changes
        assert(difference.insertions.count == 2, "Expected 2 insertions")
        assert(difference.removals.count == 1, "Expected 1 removal")
        
        // Apply changes manually
        var result = flattenedSource
        for removal in difference.removals.reversed() {
            if case let .remove(offset, _, _) = removal {
                result.remove(at: offset)
            }
        }
        for insertion in difference.insertions {
            if case let .insert(offset, element, _) = insertion {
                result.insert(element, at: offset)
            }
        }
        assert(result == flattenedTarget, "Applying difference should result in flattened target")
    }
}
