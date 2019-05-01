//
//  FuncionAleatoria.swift
//  project
//
//  Created by Abraham Muro on 4/13/19.
//  Copyright © 2019 Abraham Muro. All rights reserved.
//
import Foundation
import CoreGraphics

public extension CGFloat{
    
    
    public static func random() -> CGFloat
    {
        
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    public static func random(min min : CGFloat, max : CGFloat) -> CGFloat{
        
        return CGFloat.random() * (max - min) + min
    }
    
    
}
