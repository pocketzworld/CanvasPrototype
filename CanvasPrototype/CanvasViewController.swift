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
    
    private var canvasModel: CanvasModel? {
      didSet {
        DispatchQueue.main.async { [weak self] in
          return self?.updateViews()
        }
      }
    }
    
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
        let cancelEditGesture = UITapGestureRecognizer(target: self, action: #selector(dismissTextPicker))
        textEditContainer.addGestureRecognizer(cancelEditGesture)
    }

    private func layoutForNotEditing() {
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItems = nil
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .done, target: self, action: #selector(edit))
        canvas.widgetContainerView?.isUserInteractionEnabled = false
    }
    
    private func layoutForEditing() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(save))
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(named: "icon_text"), style: .done, target: self, action: #selector(addText)),
            UIBarButtonItem(image: UIImage(named: "icon_image"), style: .done, target: self, action: #selector(addImage)),
            UIBarButtonItem(image: UIImage(named: "icon_background"), style: .done, target: self, action: #selector(chooseBackground))
        ]
        canvas.widgetContainerView?.isUserInteractionEnabled = true
    }
  
    private func updateViews() {
      print("reloading views")
        
      if let color = canvasModel?.backgroundColor {
        canvas.backgroundColor = UIColor(hexString: color)
      }
      
      // remove all widget views
      canvas.widgetContainerView?.removeFromSuperview()
      
      // add widget views from canvasModel
      if let widgets = canvasModel?.widgets {
        for widget in widgets {
          // create and add widgetView to subviews
          if widget.type == "sticker" {
            let widgetView = StickerWidgetView()
            widgetView.widgetModel = widget
            view.addSubview(widgetView)
          } else if widget.type == "text" {
            let widgetView = TextWidgetView()
            view.addSubview(widgetView)
            widgetView.widgetModel = widget
          }
        }
      }
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
      
        var newCanvasModel = CanvasModel()
        newCanvasModel.backgroundColor = canvas.backgroundColor?.toHexString()
        
        if let canvasSubViews = canvas.widgetContainerView?.subviews {
            var widgetModels = [WidgetModel]()
            
            for subView in canvasSubViews {
                if let widgetView = subView as? WidgetView, let widget = widgetView.widgetModel {
                    var model = widget
                    model.transform = widgetView.transform
                    widgetModels.append(model)
                }
            }
            
            newCanvasModel.widgets = widgetModels
        }
      
        if let jsonContent = try? JSONEncoder().encode(newCanvasModel),
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
        canvas.bringSubviewToFront(textEditContainer)
        textEditContainer.isHidden = false
        textEditField.becomeFirstResponder()
        textEditField.text = editing
    }
    
    @objc private func dismissTextPicker() {
        textEditContainer.isHidden = true
        textEditField.resignFirstResponder()
        textEditField.text = nil
    }
}

extension CanvasViewController: WidgetViewProtocol {
    
    func didInteract(sender: WidgetView) {
        canvas.widgetContainerView?.bringSubviewToFront(sender)
    }
    
    func didTap(sender: WidgetView) {
        canvas.widgetContainerView?.bringSubviewToFront(sender)
    }
  
    func didRemoveWidget() {
        // no op?
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
        guard let text = textField.text else { return false }
        
        let widget = TextWidgetView()
        widget.delegate = self
        widget.widgetModel = WidgetModel.textWidgetModel(text: text)
        widget.center = canvas.center
        canvas.addWidget(widget)
        
        dismissTextPicker()

        return true
    }
    
}
