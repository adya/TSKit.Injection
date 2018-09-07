import Quick
import Nimble

private protocol AnyDummy {}

private protocol AnyUnknown {}

private class Dummy: AnyDummy {}

class InjectorTestSpec: QuickSpec {
    
    override func spec() {
        
        describe("The injector") {
            
            context("When configured with rule to inject Dummy for AnyDummy") {
                beforeEach {
                    Injector.configure(with: [InjectionRule(injectable: AnyDummy.self) {
                        return Dummy()
                        }])
                }
                
                it("Should inject an object of type Dummy") {
                    let object = try? Injector.inject(AnyDummy.self)
                    expect(object).toNot(beNil())
                    expect(object!).to(beAKindOf(Dummy.self))
                }
                
                it("Should fail to inject objects of unknown type") {
                    let object = try? Injector.inject(AnyUnknown.self)
                    expect(object).to(beNil())
                }
            }
            
            context("When not configured with proper rule") {
                beforeEach {
                    Injector.reset()
                }
                
                it("Should fail to inject anything") {
                    let object1 = try? Injector.inject(AnyDummy.self)
                    let object2 = try? Injector.inject(AnyUnknown.self)
                    
                    expect(object1).to(beNil())
                    expect(object2).to(beNil())
                }
            }
        }
    }
}
