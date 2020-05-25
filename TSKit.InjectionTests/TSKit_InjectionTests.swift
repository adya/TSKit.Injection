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
    
    func testImplicitExplicitOfConcreteType() {
        XCTAssertNoThrow(try Injector.inject(Dummy.self))
    }
    
    func testImplicitExplicitOfForcedType() {
        XCTAssertNoThrow(try Injector.inject(Dummy?.self))
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}

class Dummy {}
