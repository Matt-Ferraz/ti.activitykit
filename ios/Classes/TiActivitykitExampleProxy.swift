//
//  TiActivitykitExampleProxy.swift
//  ti.activitykit
//

import TitaniumKit
import ActivityKit

@objc(TiActivitykitExampleProxy)
class TiActivitykitExampleProxy: TiProxy {
  
  @objc(getMessage:)
  func getMessage(arguments: Array<Any>?) -> String {
    return "ActivityKit module is loaded"
  }
  
  @objc(checkSupport:)
  func checkSupport(arguments: Array<Any>?) -> Bool {
    if #available(iOS 16.1, *) {
      return ActivityAuthorizationInfo().areActivitiesEnabled
    } else {
      return false
    }
  }
}