/// - Since: 01/20/2018
/// - Author: Arkadii Hlushchevskyi
/// - Copyright: © 2018. Arkadii Hlushchevskyi.
/// - Seealso: https://github.com/adya/TSKit.Injection/blob/master/LICENSE.md

/// Convenient way to pass in injection rules into `Injector`.
public protocol InjectionPreset {
    
    /// Rules to be used by `Injector`.
    var rules : [InjectionRule] {get}
}

@available(*, deprecated, renamed: "InjectionPreset")
public typealias InjectionRulesPreset = InjectionPreset
