//
//  ActorConformanceTests.swift
//  
//
//  Created by Kolos Foltanyi on 06/07/2024.
//

import MacroTesting
import XCTest
import SwiftSyntax
@testable import Mockable

final class ActorConformanceTests: MockableMacroTestCase {
    func test_actor_requirement() {
        assertMacro {
          """
          @Mockable
          protocol Test: Actor {
              var foo: Int { get }
              nonisolated var quz: Int { get }
              func bar(number: Int) -> Int
              nonisolated func baz(number: Int) -> Int
          }
          """
        } expansion: {
            """
            protocol Test: Actor {
                var foo: Int { get }
                nonisolated var quz: Int { get }
                func bar(number: Int) -> Int
                nonisolated func baz(number: Int) -> Int
            }

            #if MOCKING
            actor MockTest: Test, MockableService {
                private let mocker = Mocker<MockTest>()
                @available(*, deprecated, message: "Use given(_ service:) of Mockable instead. ")
                nonisolated func given() -> ReturnBuilder {
                    .init(mocker: mocker)
                }
                @available(*, deprecated, message: "Use when(_ service:) of Mockable instead. ")
                nonisolated func when() -> ActionBuilder {
                    .init(mocker: mocker)
                }
                @available(*, deprecated, message: "Use verify(_ service:) of MockableTest instead. ")
                nonisolated func verify(with assertion: @escaping MockableAssertion) -> VerifyBuilder {
                    .init(mocker: mocker, assertion: assertion)
                }
                func reset(_ scopes: Set<MockerScope> = .all) {
                    mocker.reset(scopes: scopes)
                }
                init(policy: MockerPolicy? = nil) {
                    if let policy {
                        mocker.policy = policy
                    }
                }
                func bar(number: Int) -> Int {
                    let member: Member = .m3_bar(number: .value(number))
                    return mocker.mock(member) { producer in
                        let producer = try cast(producer) as (Int) -> Int
                        return producer(number)
                    }
                }
                nonisolated func baz(number: Int) -> Int {
                    let member: Member = .m4_baz(number: .value(number))
                    return mocker.mock(member) { producer in
                        let producer = try cast(producer) as (Int) -> Int
                        return producer(number)
                    }
                }
                var foo: Int {
                    get {
                        let member: Member = .m1_foo
                        return mocker.mock(member) { producer in
                            let producer = try cast(producer) as () -> Int
                            return producer()
                        }
                    }
                }
                nonisolated var quz: Int {
                    get {
                        let member: Member = .m2_quz
                        return mocker.mock(member) { producer in
                            let producer = try cast(producer) as () -> Int
                            return producer()
                        }
                    }
                }
                enum Member: Matchable, CaseIdentifiable {
                    case m1_foo
                    case m2_quz
                    case m3_bar(number: Parameter<Int>)
                    case m4_baz(number: Parameter<Int>)
                    func match(_ other: Member) -> Bool {
                        switch (self, other) {
                        case (.m1_foo, .m1_foo):
                            return true
                        case (.m2_quz, .m2_quz):
                            return true
                        case (.m3_bar(number: let leftNumber), .m3_bar(number: let rightNumber)):
                            return leftNumber.match(rightNumber)
                        case (.m4_baz(number: let leftNumber), .m4_baz(number: let rightNumber)):
                            return leftNumber.match(rightNumber)
                        default:
                            return false
                        }
                    }
                }
                struct ReturnBuilder: EffectBuilder {
                    private let mocker: Mocker<MockTest>
                    init(mocker: Mocker<MockTest>) {
                        self.mocker = mocker
                    }
                    var foo: FunctionReturnBuilder<MockTest, ReturnBuilder, Int, () -> Int> {
                        .init(mocker, kind: .m1_foo)
                    }
                    var quz: FunctionReturnBuilder<MockTest, ReturnBuilder, Int, () -> Int> {
                        .init(mocker, kind: .m2_quz)
                    }
                    func bar(number: Parameter<Int>) -> FunctionReturnBuilder<MockTest, ReturnBuilder, Int, (Int) -> Int> {
                        .init(mocker, kind: .m3_bar(number: number))
                    }
                    func baz(number: Parameter<Int>) -> FunctionReturnBuilder<MockTest, ReturnBuilder, Int, (Int) -> Int> {
                        .init(mocker, kind: .m4_baz(number: number))
                    }
                }
                struct ActionBuilder: EffectBuilder {
                    private let mocker: Mocker<MockTest>
                    init(mocker: Mocker<MockTest>) {
                        self.mocker = mocker
                    }
                    var foo: FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m1_foo)
                    }
                    var quz: FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m2_quz)
                    }
                    func bar(number: Parameter<Int>) -> FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m3_bar(number: number))
                    }
                    func baz(number: Parameter<Int>) -> FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m4_baz(number: number))
                    }
                }
                struct VerifyBuilder: AssertionBuilder {
                    private let mocker: Mocker<MockTest>
                    private let assertion: MockableAssertion
                    init(mocker: Mocker<MockTest>, assertion: @escaping MockableAssertion) {
                        self.mocker = mocker
                        self.assertion = assertion
                    }
                    var foo: FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m1_foo, assertion: assertion)
                    }
                    var quz: FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m2_quz, assertion: assertion)
                    }
                    func bar(number: Parameter<Int>) -> FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m3_bar(number: number), assertion: assertion)
                    }
                    func baz(number: Parameter<Int>) -> FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m4_baz(number: number), assertion: assertion)
                    }
                }
            }
            #endif
            """
        }
    }
}
