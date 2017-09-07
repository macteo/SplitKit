//
//  ImageViewController.swift
//  SplitKit Example
//
//  Created by Matteo Gavagnin on 07/09/2017.
//  Copyright © 2017 Dolomate.
//  See LICENSE file for more details.
//  

import UIKit
import MobileCoreServices

@objc class ImageViewController: UIViewController {
    let imageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.frame = view.bounds
        imageView.layer.borderWidth = 0.0
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        view.addSubview(imageView)
        imageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        imageView.isUserInteractionEnabled = true
        
        if #available(iOS 11.0, *) {
            let dragInteraction = UIDragInteraction(delegate: self)
            imageView.addInteraction(dragInteraction)
            let dropInteraction = UIDropInteraction(delegate: self)
            view.addInteraction(dropInteraction)
        }
    }
}

extension ImageViewController: UIDragInteractionDelegate {
    @available(iOS 11.0, *)
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        guard let image = imageView.image else { return [] }
        let provider = NSItemProvider(object: image)
        let item = UIDragItem(itemProvider: provider)
        item.localObject = image
        return [item]
    }
}

extension ImageViewController: UIDropInteractionDelegate {
    @available(iOS 11.0, *)
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.hasItemsConforming(toTypeIdentifiers: [kUTTypeImage as String]) && session.items.count == 1
    }

    @available(iOS 11.0, *)
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        let dropLocation = session.location(in: view)
        let operation: UIDropOperation
        if imageView.frame.contains(dropLocation) {
            operation = session.localDragSession == nil ? .copy : .move
        } else {
            operation = .cancel
        }
        return UIDropProposal(operation: operation)
    }
    
    @available(iOS 11.0, *)
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        session.loadObjects(ofClass: UIImage.self) { [unowned self] imageItems in
            let images = imageItems as! [UIImage]
            self.imageView.image = images.first
        }
    }
}
