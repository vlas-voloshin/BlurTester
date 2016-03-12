//
//  SettingsViewModel.swift
//  BlurTester
//
//  Created by Vlas Voloshin on 12/03/2016.
//  Copyright © 2016 Vlas Voloshin. All rights reserved.
//

import Foundation

struct SettingsViewModel {

    let pages: [SettingsPageViewModel]

}

struct SettingsPageViewModel {

    let name: String
    let inspectors: [InspectorViewModel]

}
