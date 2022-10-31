//
//  AppDelegate.swift
//  OnRewind
//
//  Created by Sergei Mikhan on 4/3/18.
//  Copyright © 2018 Sergei Mikhan. All rights reserved.
//

import UIKit
import Astrarium

import OnRewindSDK
import Dioptra

#if SPORTBUFF_ENABLED
import SportBuff
#endif

import Gnomon

import onrewindshared

@UIApplicationMain

public class AppDelegate: Astrarium.AppDelegate {

  public override var services: [ServiceIds?] { return [
    .ui
    ]
  }

  public override init() {
    super.init()
#if CHROMECAST_ENABLED
    OnRewind.set(receiverAppID: "A4066AA6")
#endif

#if SPORTBUFF_ENABLED
    SportBuff.initialize(
      userToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJCdWZmVXAgU0RLIFVzZXJzIiwiY2lkIjoxLCJleHAiOjE3NDI2NzYyNjcsImlhdCI6MTY0MjY3MjY2NywiaXNzIjoiQnVmZlVwIiwicm9sZSI6MCwic3ViIjoiTGVmdGVyaXMyMzI0MzI1IiwidWlkIjo2NDQ4MjEsInV1aWQiOiJhMjlhMDU3NS1jYWMzLTExZWItODlhMS0wMmRmYjM4NTVmZWQifQ.qx3YyKg8JMgb_ijRx1Esg0hUt9NZBIOIie31bl4Wvi0"
    )
#endif
    Gnomon.logging = true
  }

  public var window: UIWindow? {
    get { return Services[.ui]?.window }
    set { assertionFailure("window setter should not be called directly") }
  }
}
