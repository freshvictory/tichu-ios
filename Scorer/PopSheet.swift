//
//  PopSheet.swift
//  Scorer
//
//  Created by Justin Renjilian on 1/19/20.
//  Copyright © 2020 Justin Renjilian. All rights reserved.
//

import SwiftUI

public extension View {
    /// Creates an `ActionSheet` on an iPhone or the equivalent `popover` on an iPad, in order to work around `.actionSheet` crashing on iPad (`FB7397761`).
    ///
    /// - Parameters:
    ///     - isPresented: A `Binding` to whether the action sheet should be shown.
    ///     - content: A closure returning the `PopSheet` to present.
    func popSheet<T>(item: Binding<T?>, arrowEdge: Edge = .bottom, attachmentAnchor: PopoverAttachmentAnchor = .rect(.bounds), content: @escaping (T) -> PopSheet<T>) -> some View
        where T: Identifiable {
        Group {
            if UIDevice.current.userInterfaceIdiom == .pad {
                popover(item: item, attachmentAnchor: attachmentAnchor, arrowEdge: arrowEdge, content: { i in content(i).popover(item: item) })
            } else {
                actionSheet(item: item, content: { i in content(i).actionSheet() })
            }
        }
    }
}

/// A `Popover` on iPad and an `ActionSheet` on iPhone.
public struct PopSheet<T> where T: Identifiable {
    let title: Text
    let message: Text?
    let buttons: [PopSheet.Button<T>]

    /// Creates an action sheet with the provided buttons.
    public init(title: Text, message: Text? = nil, buttons: [PopSheet.Button<T>] = []) {
        self.title = title
        self.message = message
        self.buttons = buttons
    }

    /// Creates an `ActionSheet` for use on an iPhone device
    func actionSheet() -> ActionSheet {
        ActionSheet(title: title, message: message, buttons: buttons.map({ popButton in
            // convert from PopSheet.Button to ActionSheet.Button (i.e., Alert.Button)
            switch popButton.kind {
            case .default: return .default(popButton.label, action: popButton.action)
            case .cancel: return .cancel(popButton.label, action: popButton.action)
            case .destructive: return .destructive(popButton.label, action: popButton.action)
            }
        }))
    }

    /// Creates a `.popover` for use on an iPad device
    func popover(item: Binding<T?>) -> some View {
        return VStack {
            List(0..<self.buttons.count, id: \.self) { index in
                Group {
                    SwiftUI.Button(action: {
                        item.wrappedValue = nil
                        
                        DispatchQueue.main.async {
                            self.buttons[index].action?()
                        }
                    }) {
                        self.buttons[index].label
                    }
                }
            }
        }
    }

    /// A button representing an operation of an action sheet or popover presentation.
    ///
    /// Basically duplicates `ActionSheet.Button` (i.e., `Alert.Button`).
    public struct Button<T> where T : Identifiable {
        let kind: Kind
        let label: Text
        let action: (() -> Void)?
        enum Kind { case `default`, cancel, destructive }

        /// Creates a `Button` with the default style.
        public static func `default`(_ label: Text, action: (() -> Void)? = {}) -> Self {
            Self(kind: .default, label: label, action: action)
        }

        /// Creates a `Button` that indicates cancellation of some operation.
        public static func cancel(_ label: Text, action: (() -> Void)? = {}) -> Self {
            Self(kind: .cancel, label: label, action: action)
        }

        /// Creates an `Alert.Button` that indicates cancellation of some operation.
        public static func cancel(_ action: (() -> Void)? = {}) -> Self {
            Self(kind: .cancel, label: Text("Cancel"), action: action)
        }

        /// Creates an `Alert.Button` with a style indicating destruction of some data.
        public static func destructive(_ label: Text, action: (() -> Void)? = {}) -> Self {
            Self(kind: .destructive, label: label, action: action)
        }
    }
}
