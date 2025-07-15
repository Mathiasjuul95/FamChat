//
//  InputAssistantHider.swift
//  FamChat
//
//  Created by Mathias Juul on 10/07/2025.
//

import Foundation
import UIKit

extension UIViewController {
    open override var inputAssistantItem: UITextInputAssistantItem {
        let item = super.inputAssistantItem
        item.leadingBarButtonGroups = []
        item.trailingBarButtonGroups = []
        return item
    }
}
