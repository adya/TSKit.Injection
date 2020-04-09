// - Since: 01/20/2018
// - Author: Arkadii Hlushchevskyi
// - Copyright: © 2020. Arkadii Hlushchevskyi.
// - Seealso: https://github.com/adya/TSKit.Injection/blob/master/LICENSE.md

/// Represents an error occurred during injection.
public enum InjectionError : Error {
    
    /// Represents failed attempt to cast provided parameter to the type required in the injection closure.
    case parameterCastingError
    
    /// Represents failed attempt to inject type for which `Injector` either hasn't got suitable `InjectionRule` or provided rule was invalid.
    case undefinedInjectionError
}
