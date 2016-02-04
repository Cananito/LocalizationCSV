//
//  ViewController.swift
//  Localization
//
//  Created by Rogelio Gudino on 9/9/15.
//  Copyright (c) 2015 Rogelio Gudino. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var label: UILabel?
    override func viewDidLoad() {
        super.viewDidLoad()
        let t = "Test"
        label?.text = NSLocalizedString("\(t)", comment: "")
    }
}

