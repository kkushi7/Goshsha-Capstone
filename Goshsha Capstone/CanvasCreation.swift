//
//  CanvasCreation.swift
//  Goshsha Capstone
//
//  Created by Joana Ugarte on 11/12/24.
//

import UIKit

extension UIViewController {
    
    func setupCanvas(below viewAbove: UIView? = nil) -> UIView {
        let canvasView = UIImageView()
        canvasView.backgroundColor = UIColor(red: 255/255, green: 192/255, blue: 203/255, alpha: 1.0)
        canvasView.layer.cornerRadius = 10
        canvasView.clipsToBounds = true //round the canvas but doesnt need to be
        canvasView.layer.borderWidth = 1
        canvasView.layer.borderColor = UIColor.lightGray.cgColor
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        
        // add canvas view to the main view
        view.addSubview(canvasView)
        
        // middle page setup
        var constraints = [
            canvasView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            canvasView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80)
        ]
        
    
        // used so when in edit scrapbook the canvas will be placed under the toolbar
        if let viewAbove = viewAbove {
            constraints.append(canvasView.topAnchor.constraint(equalTo: viewAbove.bottomAnchor, constant: 20))
        } else {
            constraints.append(canvasView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80))
        }
        
        NSLayoutConstraint.activate(constraints)
        
        return canvasView
    }
}
