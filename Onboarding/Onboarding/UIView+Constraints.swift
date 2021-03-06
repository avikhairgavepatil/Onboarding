//
//  UIView+Constraints.swift
//  Onboarding
//
//  Created by Jairo Eli de Leon on 3/31/18.
//  Copyright © 2018 DevMountain. All rights reserved.
//

import UIKit

//
// Solution based on http://chris.eidhof.nl/post/micro-autolayout-dsl/ & https://github.com/simoneconnola/Constrainable
//

extension NSLayoutConstraint {

  func withMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {

    let newConstraint = NSLayoutConstraint(
      item: firstItem as Any,
      attribute: firstAttribute,
      relatedBy: relation,
      toItem: secondItem,
      attribute: secondAttribute,
      multiplier: multiplier,
      constant: constant)

    newConstraint.priority = priority
    newConstraint.shouldBeArchived = self.shouldBeArchived
    newConstraint.identifier = self.identifier

    return newConstraint
  }
}

public protocol Constrainable {
  var topAnchor: NSLayoutYAxisAnchor { get }
  var bottomAnchor: NSLayoutYAxisAnchor { get }
  var leftAnchor: NSLayoutXAxisAnchor { get }
  var rightAnchor: NSLayoutXAxisAnchor { get }
  var leadingAnchor: NSLayoutXAxisAnchor { get }
  var trailingAnchor: NSLayoutXAxisAnchor { get }
  var centerXAnchor: NSLayoutXAxisAnchor { get }
  var centerYAnchor: NSLayoutYAxisAnchor { get }
  var widthAnchor: NSLayoutDimension { get }
  var heightAnchor: NSLayoutDimension { get }
}

extension UIView: Constrainable {}
extension UILayoutGuide: Constrainable {}

public extension Constrainable {

  @discardableResult func activate(_ constraintDescriptions: [Constraint]) -> [NSLayoutConstraint] {
    if let view = self as? UIView {
      view.translatesAutoresizingMaskIntoConstraints = false
    }
    let constraints = constraintDescriptions.map { $0(self) }
    NSLayoutConstraint.activate(constraints)
    return constraints
  }
}

public typealias Constraint = (_ constrainable: Constrainable) -> NSLayoutConstraint

public enum ConstraintsRelation {
  case equal, lessThanOrEqual, greaterThanOrEqual
}

public func constraint<Anchor, Axis>(_ originKeyPath: KeyPath<Constrainable, Anchor>, to destinationKeyPath: KeyPath<Constrainable, Anchor>, of destination: Constrainable, relation: ConstraintsRelation = .equal, offset: CGFloat = 0, multiplier: CGFloat = 1, priority: UILayoutPriority = .required) -> Constraint where Anchor: NSLayoutAnchor<Axis> {
  return { constrainable in
    let constraint: NSLayoutConstraint
    switch relation {
    case .equal:
      constraint = constrainable[keyPath: originKeyPath].constraint(equalTo: destination[keyPath: destinationKeyPath], constant: offset).withMultiplier(multiplier)
    case .lessThanOrEqual:
      constraint =  constrainable[keyPath: originKeyPath].constraint(lessThanOrEqualTo: destination[keyPath: destinationKeyPath], constant: offset).withMultiplier(multiplier)
    case .greaterThanOrEqual:
      constraint =  constrainable[keyPath: originKeyPath].constraint(greaterThanOrEqualTo: destination[keyPath: destinationKeyPath], constant: offset).withMultiplier(multiplier)
    }
    constraint.priority = priority
    return constraint
  }
}

public func constraint<Anchor, Axis>(same keyPath: KeyPath<Constrainable, Anchor>, as destination: Constrainable, relation: ConstraintsRelation = .equal, offset: CGFloat = 0, multiplier: CGFloat = 1, priority: UILayoutPriority = .required) -> Constraint where Anchor: NSLayoutAnchor<Axis> {
  return constraint(keyPath, to: keyPath, of: destination, relation: relation, offset: offset, multiplier: multiplier, priority: priority)
}

public func constraint<LayoutDimension>(_ originKeyPath: KeyPath<Constrainable, LayoutDimension>, to destinationKeyPath: KeyPath<Constrainable, LayoutDimension>, of destination: Constrainable, relation: ConstraintsRelation = .equal, offset: CGFloat = 0, multiplier: CGFloat = 1, priority: UILayoutPriority = .required) -> Constraint where LayoutDimension: NSLayoutDimension {
  return { constrainable in
    let constraint: NSLayoutConstraint
    switch relation {
    case .equal:
      constraint = constrainable[keyPath: originKeyPath].constraint(equalTo: destination[keyPath: destinationKeyPath], multiplier: multiplier, constant: offset)
    case .lessThanOrEqual:
      constraint = constrainable[keyPath: originKeyPath].constraint(lessThanOrEqualTo: destination[keyPath: destinationKeyPath], multiplier: multiplier, constant: offset)
    case .greaterThanOrEqual:
      constraint = constrainable[keyPath: originKeyPath].constraint(greaterThanOrEqualTo: destination[keyPath: destinationKeyPath], multiplier: multiplier, constant: offset)
    }
    constraint.priority = priority
    return constraint
  }
}

public func constraint<LayoutDimension>(same keyPath: KeyPath<Constrainable, LayoutDimension>, as destination: Constrainable, relation: ConstraintsRelation = .equal, offset: CGFloat = 0, multiplier: CGFloat = 1, priority: UILayoutPriority = .required) -> Constraint where LayoutDimension: NSLayoutDimension {
  return constraint(keyPath, to: keyPath, of: destination, relation: relation, offset: offset, multiplier: multiplier, priority: priority)
}

public func constraint<LayoutDimension>(_ keyPath: KeyPath<Constrainable, LayoutDimension>, to constant: CGFloat, priority: UILayoutPriority = .required) -> Constraint where LayoutDimension: NSLayoutDimension {
  return { constrainable in
    let constraint = constrainable[keyPath: keyPath].constraint(equalToConstant: constant)
    constraint.priority = priority
    return constraint
  }
}

public func constraint(sizeAs destination: Constrainable, relation: ConstraintsRelation = .equal, multiplier: CGFloat = 1) -> [Constraint] {

  let width: Constraint = { constrainable in
    constraint(same: \.widthAnchor, as: destination, relation: relation, multiplier: multiplier)(constrainable)
  }

  let height: Constraint = { constrainable in
    constraint(same: \.heightAnchor, as: destination, relation: relation, multiplier: multiplier)(constrainable)
  }

  return [width, height]
}

public func constraint(edgesTo destination: Constrainable, with insets: UIEdgeInsets = .zero) -> [Constraint] {

  let top: Constraint = { constrainable  in
    constraint(same: \.topAnchor, as: destination, offset: insets.top)(constrainable)
  }
  let bottom: Constraint = { constrainable in
    constraint(same: \.bottomAnchor, as: destination, offset: -insets.bottom)(constrainable)
  }
  let leading: Constraint = { constrainable in
    constraint(same: \.leadingAnchor, as: destination, offset: insets.left)(constrainable)
  }
  let trailing: Constraint = { constrainable in
    constraint(same: \.trailingAnchor, as: destination, offset: -insets.right)(constrainable)
  }

  return [top, bottom, leading, trailing]
}
