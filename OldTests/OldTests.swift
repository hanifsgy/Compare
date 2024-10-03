//
//  OldTests.swift
//  OldTests
//
//  Created by Muhammad Hanif Sugiyanto on 03/10/24.
//

import Testing
import DifferenceKit
@testable import Old

struct OldTests {

    // MARK: - Difference
    /// Supposed we have one source and one target
    /// the expectations is
    /// - Vincent, from idx 0 moved into idx 1
    /// - Butch was inserted into idx 2
    /// so the final sources should be
    /// - Jules, Vincent, Butch
    @Test("Difference Check ChangeSet 1")
    func testsDifference() async throws {
        let source = [
            User(id: 0, name: "Vincent"),
            User(id: 1, name: "Jules")
        ]
        let target = [
            User(id: 1, name: "Jules"),
            User(id: 0, name: "Vincent"),
            User(id: 2, name: "Butch")
        ]
        let changeset = StagedChangeset(source: source, target: target)
        /// all changes can be applied in a single stage
        /// why? actually we have two actions right
        /// stage = represents a set of non-conflicting changes that can be applied together
        /// the algorithm paul heckel tries to minimize the number of stages needed to transform the source into target
        assert(changeset.count == 1)
        let firstChangeset = changeset[0]
        assert(firstChangeset.data == target)
        assert(firstChangeset.elementInserted == [ElementPath(element: 2, section: 0)])
        assert(firstChangeset.elementDeleted.isEmpty)
        let expectedMoves = [(source: ElementPath(element: 0, section: 0), target: ElementPath(element: 1, section: 0))]
        assert(firstChangeset.elementMoved.count == expectedMoves.count)
    }
    /// This test verifies that the StagedChangeset correctly handles complex updates that require multiple stages.
    /// 1. Supposed we have a source array of ComplexUsers with initial versions.
    /// 2. We create a target array where:
    ///    - Charlie and Alice have updated versions
    ///    - The order is changed (Charlie moves to the front)
    /// 3. We expect the changeset to have two stages:
    ///    - First stage: Update Charlie and Alice's versions
    ///    - Second stage: Move Charlie to the front of the array
    @Test("Difference Check Forced Multiple Stages")
    func testsDifferenceForcedMultipleStages() async throws {
        let source = [
            ComplexUser(id: 0, name: "Alice", version: 1),
            ComplexUser(id: 1, name: "Bob", version: 1),
            ComplexUser(id: 2, name: "Charlie", version: 1)
        ]
        
        let target = [
            ComplexUser(id: 2, name: "Charlie", version: 2),
            ComplexUser(id: 0, name: "Alice", version: 2),
            ComplexUser(id: 1, name: "Bob", version: 1)
        ]
        
        let changeset = StagedChangeset(source: source, target: target)
        
        assert(changeset.count == 2, "Expected 2 stages, but got \(changeset.count)")
        
        let firstStage = changeset[0]
        let secondStage = changeset[1]
        
        // First stage: Update Charlie and Alice
        assert(firstStage.elementUpdated.count == 2)
        assert(firstStage.elementUpdated.contains(ElementPath(element: 2, section: 0)))
        assert(firstStage.elementUpdated.contains(ElementPath(element: 0, section: 0)))
        assert(firstStage.elementMoved.isEmpty)
        
        // Second stage: Move Charlie to the front
        assert(secondStage.elementUpdated.isEmpty)
        assert(secondStage.elementMoved.count == 1)
        assert(secondStage.elementMoved.first?.source == ElementPath(element: 2, section: 0))
        assert(secondStage.elementMoved.first?.target == ElementPath(element: 0, section: 0))
        
        print("Multiple stages verified successfully!")
    }
    /// This test verifies that the StagedChangeset correctly handles a complex multi-section scenario.
    /// It involves multiple sections with various operations including updates, inserts, deletes, and moves
    /// across different sections.
    ///
    /// Source:
    /// - Section 1: [Alice(v1), Bob(v1), Charlie(v1)]
    /// - Section 2: [David(v1), Eve(v1)]
    ///
    /// Target:
    /// - Section 1: [Charlie(v2), Frank(v1), Alice(v2)]
    /// - Section 2: [Eve(v2), Bob(v1)]
    /// - Section 3: [Grace(v1)]
    ///
    /// Expected changes:
    /// Stages 1 (Element Updates)
    /// - Update Charlie, Alice, Eve to version 2
    /// Stages 2 (Structure Changes in Section 1)
    /// - Insert Frank into Section 1
    /// - Move Charlies to the front Section 1
    /// Stages 3 (Structure Changes in Section 2)
    /// - Move Bob from Section 1 to Section 2
    /// - Delete David from Section 2
    /// Stages 4 (New Section)
    /// - Insert new Section 3
    /// - Insert Grace into Section 3
    ///
    @Test("Difference Check Complex Multi-Section Scenario")
    func testsDifferenceComplexMultiSection() async throws {
        let source = [
            ArraySection(model: "Section 1", elements: [
                ComplexUser(id: 0, name: "Alice", version: 1),
                ComplexUser(id: 1, name: "Bob", version: 1),
                ComplexUser(id: 2, name: "Charlie", version: 1)
            ]),
            ArraySection(model: "Section 2", elements: [
                ComplexUser(id: 3, name: "David", version: 1),
                ComplexUser(id: 4, name: "Eve", version: 1)
            ])
        ]
        let target = [
            ArraySection(model: "Section 1", elements: [
                ComplexUser(id: 2, name: "Charlie", version: 2),
                ComplexUser(id: 5, name: "Frank", version: 1),
                ComplexUser(id: 0, name: "Alice", version: 2)
            ]),
            ArraySection(model: "Section 2", elements: [
                ComplexUser(id: 4, name: "Eve", version: 2),
                ComplexUser(id: 1, name: "Bob", version: 1)
            ]),
            ArraySection(model: "Section 3", elements: [
                ComplexUser(id: 6, name: "Grace", version: 1)
            ])
        ]
        
        let stagedChangeset = StagedChangeset(source: source, target: target)
        
        print("Number of stages: \(stagedChangeset.count)")
        
        var totalUpdates = 0
        var totalMoves = 0
        var totalInserts = 0
        var totalDeletes = 0
        var totalSectionInserts = 0
        var totalSectionDeletes = 0

        for (index, stage) in stagedChangeset.enumerated() {
            print("Stage \(index + 1):")
            print("  Updates: \(stage.elementUpdated)")
            print("  Moves: \(stage.elementMoved)")
            print("  Inserts: \(stage.elementInserted)")
            print("  Deletes: \(stage.elementDeleted)")
            print("  Section Inserts: \(stage.sectionInserted)")
            print("  Section Deletes: \(stage.sectionDeleted)")

            totalUpdates += stage.elementUpdated.count
            totalMoves += stage.elementMoved.count
            totalInserts += stage.elementInserted.count
            totalDeletes += stage.elementDeleted.count
            totalSectionInserts += stage.sectionInserted.count
            totalSectionDeletes += stage.sectionDeleted.count
        }

        // Verify final result
        var resultSource = source
        stagedChangeset.forEach { changeset in
            resultSource = changeset.data
        }
        assert(resultSource == target, "Final result should match target")
        assert(totalUpdates == 3, "Expected 3 updates in total")
        assert(totalMoves == 2, "Expected 2 moves in total")
        assert(totalInserts == 1, "Expected 1 inserts in total")
        assert(totalDeletes == 1, "Expected 1 delete in total")
        assert(totalSectionInserts == 1, "Expected 1 section insert in total")
        assert(totalSectionDeletes == 0, "Expected no section deletes")

        print("Complex multi-section scenario verified successfully!")
    }
}

struct User: Differentiable {
    let id: Int
    let name: String

    var differenceIdentifier: Int {
        return id
    }

    func isContentEqual(to source: User) -> Bool {
        return name == source.name
    }
}

extension User: Equatable { }

struct ComplexUser: Differentiable {
    let id: Int
    var name: String
    var version: Int
    
    var differenceIdentifier: Int { id }
    
    func isContentEqual(to source: ComplexUser) -> Bool {
        return name == source.name && version == source.version
    }
}

extension ComplexUser: Equatable { }
