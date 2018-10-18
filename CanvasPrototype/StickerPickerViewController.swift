//
//  StickerPickerViewController.swift
//  CanvasPrototype
//
//  Created by Jimmy Xu on 10/18/18.
//  Copyright © 2018 Highrise. All rights reserved.
//

import UIKit

class StickerPickerViewController: UIViewController {
    weak var delegate: WidgetPickerDelegate?
    let cellIdentifier = "ImageCollectionViewCell"

    var stickerNames: [String] = ["elephant", "wow", "converse", "sharkingcart", "sinistro", "sonic", "bunny", "dragon"]
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
    }

}

extension StickerPickerViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stickerNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? ImageCollectionViewCell {
            cell.imageView.image = UIImage(named: stickerNames[indexPath.item])
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let imageName = stickerNames[indexPath.item]
        let model = WidgetModel.imageWidgetModel(imageName: imageName, borderColor: nil)
        let widget = StickerWidgetView.init()
        widget.widgetModel = model
        delegate?.pickedWidget(widget)
        dismiss(animated: true, completion: nil)
    }
    
}
