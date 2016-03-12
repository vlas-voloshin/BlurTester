//
//  InspectorViewController.swift
//  BlurTester
//
//  Created by Vlas Voloshin on 12/03/2016.
//  Copyright © 2016 Vlas Voloshin. All rights reserved.
//

import Foundation

protocol Inspector: class {

    var viewModel: InspectorViewModel? { get set }

}
