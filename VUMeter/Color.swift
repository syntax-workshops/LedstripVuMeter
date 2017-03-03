//
//  Color.swift
//  VUMeter
//
//  Created by Mathijs Bernson on 03/03/2017.
//  Copyright © 2017 Duckson. All rights reserved.
//

import Foundation

struct Color {
  let red: UInt8
  let green: UInt8
  let blue: UInt8
}

extension Color: Equatable {}
func ==(lhs: Color, rhs: Color) -> Bool {
  return lhs.red == rhs.red && lhs.blue == rhs.blue && lhs.green == rhs.green
}
