//
//  File.swift
//  VUMeter
//
//  Created by Mathijs Bernson on 03/03/2017.
//  Copyright © 2017 Duckson. All rights reserved.
//

import Foundation
import AVFoundation

class VUMeter {

  weak var delegate: VUMeterDelegate? = nil

  private let fileURL: URL
  private var timer: Timer? = nil
  private let recorder: AVAudioRecorder
  private let session: AVAudioSession
  private let recorderSettings: [String : Any] = [:]
  private let interval: TimeInterval

  init?(interval: TimeInterval) {
    session = AVAudioSession.sharedInstance()
    self.interval = interval
    do {
      let fileName = String(format: "%@_%@", UUID().uuidString, "file.txt")
      fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
      recorder = try AVAudioRecorder(url: fileURL, settings: recorderSettings)
    } catch let error {
      debugPrint(error)
      return nil
    }
  }

  deinit {
    stopUpdating()
  }

  func startUpdating(success successCallback: @escaping () -> (), failure failureCallback: @escaping () -> ()) {
    do {
      try session.setCategory(AVAudioSessionCategoryRecord)
      try session.setActive(true)

      session.requestRecordPermission { success in
        if success {
          self.startRecording()
          successCallback()
        } else {
          failureCallback()
        }
      }
    } catch let error {
      debugPrint(error)
      failureCallback()
      return
    }
  }

  private func startRecording() {
    if recorder.prepareToRecord() {
      recorder.isMeteringEnabled = true
      if recorder.record() {
        let timer = Timer(timeInterval: interval, target: self, selector: #selector(updateMeter), userInfo: nil, repeats: true)
        self.timer = timer
        RunLoop.current.add(timer, forMode: .commonModes)
      }
    }
  }

  func stopUpdating() {
    recorder.stop()
    timer?.invalidate()
    do {
      try FileManager.default.removeItem(at: fileURL)
    } catch let error {
      debugPrint(error)
    }
  }

  @objc func updateMeter() {
    recorder.updateMeters()
    let decibels = recorder.averagePower(forChannel: 0)
    delegate?.didUpdateResult(decibels: decibels)
    print("\(decibels)dB")
  }
}

func decibelsToLinear(decibels: Float, minDecibels: Float) -> Float {
  let level: Float
  if decibels < minDecibels {
    level = 0
  } else if decibels > 1 {
    level = 1
  } else {
    let root: Float = 2
    let minAmp = powf(10, 0.05 * minDecibels)
    let inverseAmpRange = 1 / (1 - minAmp)
    let amp = powf(10, 0.05 * decibels)
    let adjAmp = (amp - minAmp) * inverseAmpRange
    level = powf(adjAmp, 1 / root)
  }
  return level
}

protocol VUMeterDelegate: class {
  func didUpdateResult(decibels: Float)
}
