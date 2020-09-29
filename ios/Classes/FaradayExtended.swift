//
//  FaradayExtend.swift
//  g_faraday
//
//  Created by gix on 2020/9/21.
//

import Foundation

public struct FaradayExtension<ExtendedType> {
    /// Stores the type or meta-type of any extended type.
    public private(set) var type: ExtendedType

    /// Create an instance from the provided value.
    ///
    /// - Parameter type: Instance being extended.
    public init(_ type: ExtendedType) {
        self.type = type
    }
}

/// Protocol describing the `fa` extension points for Faraday extended types.
public protocol FaradayExtended {
    /// Type being extended.
    associatedtype ExtendedType

    /// Static Faraday extension point.
    static var fa: FaradayExtension<ExtendedType>.Type { get set }
    /// Instance Faraday extension point.
    var fa: FaradayExtension<ExtendedType> { get set }
}

public extension FaradayExtended {
    /// Static Faraday extension point.
    static var fa: FaradayExtension<Self>.Type {
        get { FaradayExtension<Self>.self }
        set {}
    }

    /// Instance Faraday extension point.
    var fa: FaradayExtension<Self> {
        get { FaradayExtension(self) }
        set {}
    }
}

extension UIViewController: FaradayExtended { }
extension NotificationCenter: FaradayExtended { }
