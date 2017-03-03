//
//  LedStrip.swift
//  LEDControl
//
//  Created by Mathijs Bernson on 17/03/16.
//  Copyright © 2016 Duckson. All rights reserved.
//

import Foundation
import UIKit

class LEDStrip {
  var ledcount: Int

  var ip: String
  let port: CUnsignedShort = 80

  var udpClient: UDPClient

  var color: UIColor = UIColor.white
  var brightness: CGFloat = 1.0

  convenience init(userDefaults: UserDefaults = UserDefaults.standard) {
    self.init(ipAddress: userDefaults.string(forKey: "ledStripIpAddress")!, count: userDefaults.integer(forKey: "ledStripCount"))
  }

  init(ipAddress: String, count: Int) {
    ledcount = count
    ip = ipAddress

    udpClient = UDPClient(ip: ip, port: port)
  }

  func reload() {
    udpClient = UDPClient(ip: ip, port: port)
  }

  func send(_ message: [UInt8]) {
    udpClient.send(message)
  }

  func clear() {
    let message = [UInt8](repeating: 0, count: ledcount * 3)
    udpClient.send(message)
  }
}
