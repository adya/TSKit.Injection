/// Convinient way to pass in injection rules into `Injector`.
public protocol InjectionPreset {
    
    /// Rules to be used by `Injector`.
    var rules : [InjectionRule] {get}
}

@available(*, deprecated, renamed: "InjectionPreset")
public typealias InjectionRulesPreset = InjectionPreset
