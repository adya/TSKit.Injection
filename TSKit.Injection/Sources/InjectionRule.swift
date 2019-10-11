// - Since: 01/20/2018
// - Author: Arkadii Hlushchevskyi
// - Copyright: © 2019. Arkadii Hlushchevskyi.
// - Seealso: https://github.com/adya/TSKit.Injection/blob/master/LICENSE.md

/// Represents an injection rule. This defines how Injector should construct concrete object for specified protocol type.
public struct InjectionRule: CustomStringConvertible {
    
    internal typealias InjectionClosure = ((Any?) throws -> Any)
    
    /// Internal holder for the type of a protocol being injected.
    internal let protocolType : Any.Type
    
    /// Internal holder for the specific target type of the injection.
    internal let targetType : Any.Type
    
    /// Internal holder for the type of injection destination.
    internal let destinationType : Any.Type
    
    /// Metadata of the injection represents type of concrete object that will be injected.
    private let meta : Any.Type?
    
    /// Indicates whether the injection should reuse object created before or not.
    internal let once : Bool
    
    /// Internal holder for an injection closure.
    internal let injection : InjectionClosure
    
    public var description : String {
        var descr = "\(protocolType)"
        if targetType != Any.Type.self { descr += " [\(self.targetType)]" }
        if destinationType != Any.Type.self { descr += " -> \(self.destinationType)" }
        if meta != nil { descr += " : \(meta!)" }
        return descr
    }
    
    private init(protocolType: Any.Type,
                 targetType: Any.Type = Any.Type.self,
                 destinationType: Any.Type = Any.Type.self,
                 once: Bool = false,
                 meta: Any.Type? = nil,
                 injection: @escaping InjectionClosure) {
        self.protocolType = protocolType
        self.targetType = targetType
        self.destinationType = destinationType
        self.once = once
        self.injection = injection
        self.meta = meta
    }
    
    /// Initializes `InjectionRule` with specified target type and injection closure with paramter.
    /// - Parameter injectable: Target protocol type to which this rule will be applied.
    /// - Parameter once: Indicates whether the injection should reuse object created before or not.
    /// - Parameter meta: Metadata of the injection represents type of the concrete object that will be injected.
    /// - Parameter injection: A closure to which type instantiation is delegated.
    /// - Parameter InjectableType: Type of injectable which must confrom to general Injectable protocol.
    public init<InjectableType> (injectable: InjectableType.Type,
                                 once: Bool = false,
                                 meta: Any.Type? = nil,
                                 injection: @escaping () throws -> InjectableType) {
        
        self.init(injectable: injectable,
                  destinationType: Any.Type.self,
                  once: once,
                  meta: meta,
                  injection: injection)
    }
    
    /// Initializes `InjectionRule` with specified target type and injection closure with paramter.
    /// - Parameter injectable: Target protocol type to which this rule will be applied.
    /// - Parameter destinationType: Type of the injection destination object.
    /// - Parameter once: Indicates whether the injection should reuse object created before or not.
    /// - Parameter meta: Metadata of the injection represents type of the concrete object that will be injected.
    /// - Parameter injection: A closure to which type instantiation is delegated.
    public init<InjectableType, DestinationType> (injectable: InjectableType.Type,
                                                  destinationType: DestinationType.Type,
                                                  once: Bool = false,
                                                  meta: Any.Type? = nil,
                                                  injection: @escaping () throws -> InjectableType) {
        
        self.init(protocolType: injectable,
                  destinationType: destinationType,
                  once: once,
                  meta: meta) { _ in try injection() }
    }
    
    /// Initializes `InjectionRule` with specified target type and injection closure with paramter.
    /// - Parameter injectable: Target protocol type to which this rule will be applied.
    /// - Parameter targetType: Type of the parameter which will be passed to the closure.
    /// - Parameter destinationType: Type of the injection destination object.
    /// - Parameter once: Indicates whether the injection should reuse object created before or not.
    /// - Parameter meta: Metadata of the injection represents type of the concrete object that will be injected.
    /// - Parameter injection: A closure to which type instantiation is delegated.
    public init<InjectableType, TargetType, DestinationType> (
        injectable: InjectableType.Type,
        targetType: TargetType.Type,
        destinationType: DestinationType.Type,
        once: Bool = false,
        meta: Any.Type? = nil,
        injection: @escaping (TargetType) throws -> InjectableType) {
        
        self.init(protocolType: injectable,
                  targetType: targetType,
                  destinationType: destinationType,
                  once: once,
                  meta: meta) {
                    guard let parameter = $0 else {
                        Injector.log.severe("Unexpected nil parameter while injecting '\(type(of: injectable))'. Expected '\(TargetType.Type.self)'.")
                        throw InjectionError.parameterCastingError
                    }
                    guard let castedParameter = parameter as? TargetType else {
                        Injector.log.severe("Failed to cast parameter for injection of '\(type(of: injectable))'. Expected '\(TargetType.Type.self)', but actual parameter is of type '\(type(of: parameter))'.")
                        throw InjectionError.parameterCastingError
                    }
                    return try injection(castedParameter)
        }
    }
    
    /// Initializes `InjectionRule` with specified target type and injection closure with paramter.
    /// - Parameter injectable: Target protocol type to which this rule will be applied.
    /// - Parameter targetType: Type of the parameter which will be passed to the closure.
    /// - Parameter once: Indicates whether the injection should reuse object created before or not.
    /// - Parameter meta: Metadata of the injection represents type of the concrete object that will be injected.
    /// - Parameter injection: A closure to which type instantiation is delegated.
    public init<InjectableType, TargetType> (
        injectable: InjectableType.Type,
        targetType: TargetType.Type,
        once: Bool = false,
        meta: Any.Type? = nil,
        injection: @escaping (TargetType) throws -> InjectableType) {
        
        self.init(injectable: injectable,
                  targetType: targetType,
                  destinationType: Any.Type.self,
                  once: once,
                  meta: meta,
                  injection: injection)
    }
    
    /// Initializes `InjectionRule` with specified target type and injection closure without parameters.
    /// - Attention: This type of injection will use a single instance to inject it wherever it's requested. (Applicable to classes, since value types will be copied during injection).
    /// - Parameter injectable: Target protocol type to which this rule will be applied.
    /// - Parameter destinationType: Type of the injection destination object.
    /// - Parameter injected: A closure to which type instantiation is delegated.
    /// - Parameter meta: Metadata of the injection represents type of the concrete object that will be injected.
    public init<InjectableType, DestinationType> (
        injectable: InjectableType.Type,
        destinationType: DestinationType.Type,
        meta: Any.Type? = nil,
        injected: @autoclosure @escaping () throws -> InjectableType) {
        self.init(protocolType: injectable,
                  once: true,
                  meta: meta) { _ in return try injected() }
    }
    
    /// Initializes `InjectionRule` with specified target type and injection closure without parameters.
    /// - Attention: This type of injection will use a single instance to inject it wherever it's requested. (Applicable to classes, since value types will be copied during injection).
    /// - Parameter injectable: Target protocol type to which this rule will be applied.
    /// - Parameter injected: A closure to which type instantiation is delegated.
    /// - Parameter meta: Metadata of the injection represents type of the concrete object that will be injected.
    public init<InjectableType> (
        injectable: InjectableType.Type,
        meta: Any.Type? = nil,
        injected: @autoclosure @escaping () throws -> InjectableType) {
        self.init(injectable: injectable,
                  destinationType: Any.Type.self,
                  meta: meta,
                  injected: try injected())
    }
}
