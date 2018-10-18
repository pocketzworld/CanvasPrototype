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
    @IBOutlet weak var widget1: WidgetView!
    @IBOutlet weak var widget2: WidgetView!
    @IBOutlet weak var widget3: WidgetView!
    
    private var canvasModel: CanvasModel?
    
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
        
        widget1.delegate = self
        widget2.delegate = self
        widget3.delegate = self
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
        guard let data = JSONString.data(using: .utf8) else { return }
        do {
            let thing = try JSONDecoder().decode(CanvasModel.self, from: data)
            canvasModel = thing
        } catch {
            print(error)
        }
    }
    
    // MARK: Actions
    
    @objc private func edit() {
        isEditingCanvas = true
    }
    
    @objc private func save() {
        isEditingCanvas = false
        
        if let canvasModel = canvasModel,
            let jsonContent = try? JSONEncoder().encode(canvasModel),
            let JSON = String(data: jsonContent, encoding: .utf8) {
            publishChanges(JSON)
        }
    }
    
    @objc private func chooseBackground() {
        // Sample
        canvas.backgroundColor = UIColor.randomColor()
    }
    
    @objc private func addImage() {
        let vc = StickerPickerViewController()
        vc.delegate = self
        let nav = UINavigationController(rootViewController: vc)
        show(nav, sender: self)
        
        
//        // Sample
//        let view = UIView(frame: CGRect(x: 20, y: 20, width: 40, height: 40))
//        view.backgroundColor = .red
//        canvas.addWidget(view)
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
            guard let snapshotString = snapshot.value as? String, snapshotString.count > 0 else { return }
            self.remoteChangesReceived(snapshotString)
        }
    }
}

extension CanvasViewController: WidgetViewProtocol {
    
    func didInteract(sender: WidgetView) {
        self.view.bringSubviewToFront(sender)
    }
    
    func didTap(sender: WidgetView) {
        print("tapped")
        self.view.bringSubviewToFront(sender)
    }
  
    func didRemoveWidget() {
      print("did remove widget from canvas")
    }
    
}

extension CanvasViewController: WidgetPickerDelegate {
    func pickedWidget(_ widget: WidgetView) {
        widget.delegate = self
        canvas.addWidget(widget)
    }
}
