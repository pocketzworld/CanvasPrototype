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
    @IBOutlet private weak var textEditContainer: UIView!
    @IBOutlet private weak var textEditField: UITextField!
    
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
        
        textEditField.delegate = self
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
    }
    
    @objc private func addText() {
        presentTextPicker(editing: nil)
    }
    
    // MARK: Remote Data
    
    private func beginMonitoring() {
        databaseReference.observe(.value) { snapshot in
            guard let snapshotString = snapshot.value as? String, snapshotString.count > 0 else { return }
            self.remoteChangesReceived(snapshotString)
        }
    }
    
    // MARK: Text Picker
    
    private func presentTextPicker(editing: String?) {
        textEditContainer.isHidden = false
        textEditField.becomeFirstResponder()
        textEditField.text = editing
    }
    
    private func dismissTextPicker() {
        textEditContainer.isHidden = true
        textEditField.resignFirstResponder()
        textEditField.text = nil
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

extension CanvasViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let widget = TextWidgetView()
        widget.delegate = self
        widget.text = textField.text
        widget.sizeToFit()
        widget.center = canvas.center
        canvas.addWidget(widget)
        
        dismissTextPicker()

        return true
    }
    
}
