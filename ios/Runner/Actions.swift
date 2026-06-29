//
//  Actions.swift
//  ClingDemo
//
//  Created by zhusanbao on 2024/8/21.
//

import Foundation

class ClingState{
    var enable = false
}

struct Actions {
    
    let name: String
    let sel: Selector
    
    let enable: ()->Bool
    
    var color: UIColor { enable() ? .blue : .gray }
}
