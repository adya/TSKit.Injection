import XCTest
@testable import TSKit_Injection

class TSKit_InjectionTests: XCTestCase {
    
    override func setUp() {
        Injector.addInjectionRule(.init(injectable: Dummy.self, injected: Dummy()))
        super.setUp()
    }
    
    override func tearDown() {
        Injector.reset()
        super.tearDown()
    }
    
    func testImplicitInjectionOfConcreteType() {
        XCTAssertNoThrow({
            let dummy: Dummy = try Injector.inject()
            _ = dummy
        })
    }
    
    func testImplicitInjectionOfForcedType() {
        XCTAssertNoThrow({
            let dummy: Dummy! = try Injector.inject()
            _ = dummy
        })
    }
    
    func testExplicitInjectionOfConcreteType() {
        XCTAssertNoThrow(try Injector.inject(Dummy.self))
    }
    
    func testExplicitInjectionOfForcedType() {
        XCTAssertNoThrow(try Injector.inject(Dummy?.self))
    }
    
    func testImplicitInjectionForDesitnationType() {
        Injector.addInjectionRule(.init(injectable: Dummy.self, destinationType: Desitnation.self) {
            DummyForDestination()
        })
        
        var dummy: Dummy!
        do {
        dummy = try Injector.inject(for: Desitnation.self)
            XCTAssertTrue(dummy is DummyForDestination)
        } catch {
            XCTFail()
        }
    }
    
    func testExplicitInjectionForDesitnationType() {
        Injector.addInjectionRule(.init(injectable: Dummy.self, destinationType: Desitnation.self) {
            DummyForDestination()
        })
        
        var dummy: Dummy!
        do {
            dummy = try Injector.inject(Dummy.self, for: Desitnation.self)
            XCTAssertTrue(dummy is DummyForDestination)
        } catch {
            XCTFail()
        }
    }
    
    func testConflictingCacheForDesitnationType() {
        Injector.addInjectionRule(.init(injectable: Dummy.self,
                                        once: true) {
            Dummy()
        })
        Injector.addInjectionRule(.init(injectable: Dummy.self,
                                        destinationType: Desitnation.self,
                                        once: true) {
            DummyForDestination()
        })
        var commonDummy: Dummy!
        var specialDummy: Dummy!
        do {
            commonDummy = try Injector.inject(Dummy.self)
            specialDummy = try Injector.inject(for: Desitnation.self)
            XCTAssertTrue(specialDummy is DummyForDestination)
            XCTAssertTrue(commonDummy is Dummy)
        } catch {
            XCTFail()
        }
    }
    
}

class Desitnation {}

class Dummy {}

class DummyForDestination: Dummy {}
