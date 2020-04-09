// - Since: 01/20/2018
// - Author: Arkadii Hlushchevskyi
// - Copyright: © 2020. Arkadii Hlushchevskyi.
// - Seealso: https://github.com/adya/TSKit.Injection/blob/master/LICENSE.md

import TSKit_Log

/**
 Highly configurable powerful injection mechanism.
 
 - Note: Best place to configure `Injector` is in the `AppDelegate`'s `init` method. (This will ensures that by the time you are injecting constants in `UIViewController`s `init` methods `Injector` will be ready for that).
 
 - Version:    1.1
 - Date:       11/22/2016
 - Since:      11/03/2016
 - Author:     AdYa
 */
public class Injector {

    fileprivate typealias Rules = [String: [String: [String: InjectionRule]]]
    fileprivate typealias Cache = [String: [String: [String: Any]]]

    /// Internal property to store configured injection rules.
    private static var rules: Rules = [:]

    private static var cache: Cache = [:]

    private static let synchronizationQueue = DispatchQueue(label: "Injector.synchronization_queue", qos: .background, attributes: .concurrent)

    /// Flag indicating whether `Injector` should output its debug logs to the console.
    public static var isDebugLoggingEnabled: Bool {
        get {
            return logger.writers.count > 0
        }
        set {
            if newValue {
                logger.writers.append(PrintLogEntryWriter(decorator: LogEntryDecorator(style: .iconic)))
            } else {
                logger.writers.removeAll()
            }
        }
    }

    private static let logger: Logger = {
        let log = Logger()
        return log
    }()

    static var log: AnyLogger {
        return logger
    }

    fileprivate static var synchronizedRules: Rules {
        get {
            return synchronizationQueue.sync { rules }
        }
        set {
            synchronizationQueue.async(flags: .barrier) { rules = newValue }
        }
    }

    fileprivate static var synchronizedCache: Cache {
        get {
            return synchronizationQueue.sync { cache }
        }
        set {
            synchronizationQueue.async(flags: .barrier) { cache = newValue }
        }
    }

    /// Replaces existing `InjectionRule`s with specified in the preset.
    /// - Parameter preset: An array of rules to be set.
    public static func configure(with preset: InjectionRulesPreset) {
        self.configure(with: preset.rules)
    }

    /// Replaces existing `InjectionRule`s with specified.
    /// - Parameter rules: An array of rules to be set.
    public static func configure(with rules: [InjectionRule]) {
        rules.forEach(add(rule:))
    }

    public static func addInjectionRule(_ rule: InjectionRule) {
        add(rule: rule)
    }

    /// Adds a single `InjectionRule` to existing rules.
    /// - Parameter rule: A rule to be added.
    private static func add(rule: InjectionRule) {
        let protocolType = String(describing: rule.protocolType)
        let targetType = String(describing: rule.targetType)
        let destinationType = String(describing: rule.destinationType)

        // Either add to existing sub-dictionary or create new one
        guard rules[protocolType] != nil else {
            rules[protocolType] = [targetType: [destinationType: rule]]
            return
        }

        guard rules[protocolType]?[targetType] != nil else {
            rules[protocolType]?[targetType] = [destinationType: rule]
            return
        }

        rules[protocolType]?[targetType]?[destinationType] = rule
    }

    /// Resets all previously configured rules.
    public static func reset() {
        synchronizedRules.removeAll()
    }

    /**
     Injects concrete type conformed to target injectable type.
     - Parameter injectable: Protocol to which injected instance conforms.
     - Parameter with parameter: Custom parameter to be used during injection.
     - Parameter for sender: Type of the injection target.
     
     - Throws:
     * InjectionError.UndefinedInjectionError
     * InjectionError.ParameterCastingError
     */
    public static func inject<InjectableType>(_ injectable: InjectableType.Type,
                                              with parameter: Any? = nil,
                                              for sender: Any.Type) throws -> InjectableType where InjectableType: Any {
        let target: Any.Type = parameter != nil ? type(of: parameter!) : Any.Type.self

        let protocolType = String(describing: injectable)
        let targetType = String(describing: target)
        let destinationType = String(describing: sender)
        let defaultType = String(describing: Any.Type.self)

        let rules = synchronizedRules

        // get rules for specific target or default
        // get rule for specific destination or default
        guard let targetRules = rules[protocolType]?[targetType] ?? rules[protocolType]?[defaultType],
              let rule = targetRules[destinationType] ?? targetRules[defaultType]
                else {
            log.severe("Didn't find any rule suitable for injection of \(protocolType) with parameter \(targetType) for \(destinationType)")
            throw InjectionError.undefinedInjectionError
        }

        let cache = synchronizedCache

        if rule.once,
           let targetCache = cache[protocolType]?[targetType] ?? cache[protocolType]?[defaultType],
           let cached = (targetCache[destinationType] ?? targetCache[defaultType] as Any) as? InjectableType {
            log.debug("Restored cached \(protocolType) with \(type(of: cached))")
            return cached
        }

        guard let injected = try rule.injection(parameter) as? InjectableType else {
            log.severe("\(protocolType) injection failed")
            throw InjectionError.undefinedInjectionError
        }
        log.debug("Successfully injected \(protocolType) with \(type(of: injected))")
        if rule.once {
            if cache[protocolType] == nil {
                synchronizedCache[protocolType] = [targetType: [destinationType: injected]]
            } else if cache[protocolType]?[targetType] == nil {
                synchronizedCache[protocolType]?[targetType] = [destinationType: injected]
            } else {
                synchronizedCache[protocolType]?[targetType]?[destinationType] = injected
            }
        }
        return injected
    }

    /**
     Injects concrete type conformed to target injectable type.
     - Parameter injectable: Protocol to which injected instance conforms.
     - Parameter parameter: Custom parameter to be used during injection.
     - Parameter for sender: Injection target.
     
     - Throws:
     * InjectionError.UndefinedInjectionError
     * InjectionError.ParameterCastingError
     */
    public static func inject<InjectableType: Any>(_ injectable: InjectableType.Type,
                                                   with parameter: Any? = nil,
                                                   for sender: Any? = nil) throws -> InjectableType {
        let sender = sender.flatMap { type(of: $0) } ?? Any.Type.self
        return try inject(injectable, with: parameter, for: sender)
    }

    public static func inject<InjectableType: Any>(with parameter: Any? = nil,
                                                   for sender: Any? = nil) throws -> InjectableType {
        return try inject(InjectableType.self, with: parameter, for: sender)
    }

    /// Prints all configured injection rules.
    public static func printConfiguration() {
        print("Configured injection rules: \n")
        self.synchronizedRules
                .flatMap { $0.1.values }.flatMap { $0.values }
                .sorted { "\($0.protocolType)".compare("\($1.protocolType)") == .orderedAscending }
                .forEach { print("\($0)") }
    }
}

