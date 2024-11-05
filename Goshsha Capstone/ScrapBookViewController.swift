//
//  ScrapBookViewController.swift
//  Goshsha Capstone
//
//  Created by Athena Yap on 10/23/24.
//

import Foundation
import UIKit

class ScrapBookViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Show a label in ScrapBook page
        view.backgroundColor = .white
                
        let label = UILabel()
        label.text = "ScrapBook"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 24)
        label.textColor = .black
        
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])


    }
}
