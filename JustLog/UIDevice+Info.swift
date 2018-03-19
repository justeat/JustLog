//
//  UIDevice+Info.swift
//  JustLog
//
//  Created by Alberto De Bortoli on 15/12/2016.
//  Copyright © 2017 Just Eat. All rights reserved.
//

import UIKit

extension UIDevice {
    
    func platform() -> String {
        var size: size_t = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0);
        var machine = [CChar](repeating: 0,  count: Int(size))
        sysctlbyname("hw.machine", &machine, &size, nil, 0);
        return String(cString: machine)
    }
}
