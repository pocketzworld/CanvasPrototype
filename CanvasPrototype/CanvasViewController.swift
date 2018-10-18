//
//  CanvasViewController.swift
//  CanvasPrototype
//
//  Created by Josh Johnson on 10/18/18.
//  Copyright © 2018 Highrise. All rights reserved.
//

import UIKit
import FirebaseDatabase

class CanvasViewController: UIViewController {
    
    private lazy var databaseReference: DatabaseReference = {
       return Database.database().reference()
    }()
    
    var isEditingCanvas: Bool = false {
        didSet {
            if isEditingCanvas {
                layoutForEditing()
            } else {
                layoutForNotEditing()
            }
        }
    }
    
    var canvas: CanvasView {
        get {
            return view as! CanvasView
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "#me"
        edgesForExtendedLayout = [ .bottom, .left, .right ]
        layoutForNotEditing()
        beginMonitoring()
    }

    private func layoutForNotEditing() {
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItems = nil
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .done, target: self, action: #selector(edit))
    }
    
    private func layoutForEditing() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(save))
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(named: "icon_text"), style: .done, target: self, action: #selector(addText)),
            UIBarButtonItem(image: UIImage(named: "icon_image"), style: .done, target: self, action: #selector(addImage)),
            UIBarButtonItem(image: UIImage(named: "icon_background"), style: .done, target: self, action: #selector(chooseBackground))
        ]
    }
    
    // MARK: Remote Data Updates
    
    private func publishChanges(_ JSONString: String) {
        databaseReference.setValue(JSONString)
    }
    
    private func remoteChangesReceived(_ JSONString: String) {
        print("Changes received: \(JSONString)")
    }
    
    // MARK: Actions
    
    @objc private func edit() {
        isEditingCanvas = true
    }
    
    @objc private func save() {
        isEditingCanvas = false
        
        // Sample
        publishChanges("[{\"content\": \"Hello, World!\", \"color\": \(UIColor.randomColor().description)}]")
    }
    
    @objc private func chooseBackground() {
        // Sample
        canvas.backgroundColor = UIColor.randomColor()
    }
    
    @objc private func addImage() {
        // Sample
        let view = UIView(frame: CGRect(x: 20, y: 20, width: 40, height: 40))
        view.backgroundColor = .red
        canvas.addWidget(view)
    }
    
    @objc private func addText() {
        // Sample
        let label = UILabel()
        label.text = "Hello World"
        label.sizeToFit()
        label.center = canvas.center
        canvas.addWidget(label)
    }
    
    // MARK: Remote Data
    
    private func beginMonitoring() {
        databaseReference.observe(.value) { snapshot in
            guard let data = snapshot.value as? String else { return }
            self.remoteChangesReceived(data)
        }
    }
}

