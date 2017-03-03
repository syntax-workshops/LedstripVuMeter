//
//  UIColor+RGB.swift
//  LEDControl
//
//  Created by Mathijs Bernson on 17/03/16.
//  Copyright © 2016 Duckson. All rights reserved.
//

import UIKit

extension UIColor {
  func rgb() -> (CGFloat, CGFloat, CGFloat) {
    var fRed: CGFloat = 0
    var fGreen: CGFloat = 0
    var fBlue: CGFloat = 0
    var fAlpha: CGFloat = 0

    if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
      let iRed = CGFloat(fRed * 255.0)
      let iGreen = CGFloat(fGreen * 255.0)
      let iBlue = CGFloat(fBlue * 255.0)

      return (iRed, iGreen, iBlue)
    } else {
      // Could not extract RGBA components
      return (0, 0, 0)
    }
  }
}
