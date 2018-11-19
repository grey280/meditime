//
//  Log.swift
//  meditation
//
//  Created by Grey Patterson on 11/18/18.
//  Copyright © 2018 Grey Patterson. All rights reserved.
//

import os.log

fileprivate let subsystem = "net.twoeighty.meditation"

struct Log{
    static var general = OSLog(subsystem: subsystem, category: "general")
    static var shortcuts = OSLog(subsystem: subsystem, category: "shortcuts")
}
