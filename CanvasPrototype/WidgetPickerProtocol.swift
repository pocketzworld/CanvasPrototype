//
//  File.swift
//  CanvasPrototype
//
//  Created by Jimmy Xu on 10/18/18.
//  Copyright © 2018 Highrise. All rights reserved.
//

import Foundation

protocol WidgetPickerDelegate: NSObjectProtocol {
    func pickedWidget(_ widget: WidgetView)
}
