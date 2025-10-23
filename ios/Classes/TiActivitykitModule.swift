//
//  TiActivitykitModule.swift
//  ti.activitykit
//

import UIKit
import TitaniumKit
import ActivityKit

@available(iOS 16.1, *)
public struct MyActivityAttributes: ActivityAttributes {
  public struct ContentState: Codable, Hashable {
    public var status: String
    public var tempoEstimado: Date
    
    public init(status: String, tempoEstimado: Date) {
      self.status = status
      self.tempoEstimado = tempoEstimado
    }
  }
  
  public var nomeDoPedido: String
  
  public init(nomeDoPedido: String) {
    self.nomeDoPedido = nomeDoPedido
  }
}

@objc(TiActivitykitModule)
class TiActivitykitModule: TiModule {

  func moduleGUID() -> String {
    return "51c2497a-0555-4408-9d90-e0532b2e8974"
  }
  
  override func moduleId() -> String! {
    return "ti.activitykit"
  }

  override func startup() {
    super.startup()
    debugPrint("[DEBUG] \(self) loaded")
  }

  @objc(isSupported:)
  func isSupported(arguments: Array<Any>?) -> Bool {
    if #available(iOS 16.1, *) {
      return ActivityAuthorizationInfo().areActivitiesEnabled
    } else {
      return false
    }
  }

  @objc(startActivity:)
  func startActivity(arguments: Array<Any>?) {
    guard #available(iOS 16.1, *) else {
      NSLog("[ERROR] Live Activities require iOS 16.1 or later")
      return
    }
    
    guard let arguments = arguments,
          let params = arguments[0] as? [String: Any],
          let nomeDoPedido = params["nomeDoPedido"] as? String else {
      NSLog("[ERROR] Invalid arguments for startActivity. Expected: {nomeDoPedido: String}")
      return
    }
    
    let attributes = MyActivityAttributes(nomeDoPedido: nomeDoPedido)
    let contentState = MyActivityAttributes.ContentState(
      status: "Processando",
      tempoEstimado: Date().addingTimeInterval(60 * 30)
    )
    
    do {
      let activity = try Activity.request(
        attributes: attributes,
        contentState: contentState
      )
      NSLog("[INFO] Activity started with ID: \(activity.id)")
      self.fireEvent("activityStarted", with: ["id": activity.id])
    } catch {
      NSLog("[ERROR] Failed to start activity: \(error.localizedDescription)")
      self.fireEvent("error", with: ["message": error.localizedDescription])
    }
  }
  
  @objc(updateActivity:)
  func updateActivity(arguments: Array<Any>?) {
    guard #available(iOS 16.1, *) else { return }
    
    guard let arguments = arguments,
          let params = arguments[0] as? [String: Any],
          let activityId = params["id"] as? String,
          let status = params["status"] as? String else {
      NSLog("[ERROR] Invalid arguments for updateActivity")
      return
    }
    
    Task {
      for activity in Activity<MyActivityAttributes>.activities {
        if activity.id == activityId {
          let updatedState = MyActivityAttributes.ContentState(
            status: status,
            tempoEstimado: Date().addingTimeInterval(60 * 15)
          )
          
          await activity.update(using: updatedState)
          NSLog("[INFO] Activity \(activityId) updated with status: \(status)")
          return
        }
      }
      
      NSLog("[ERROR] Activity with ID \(activityId) not found")
    }
  }
  
  @objc(endActivity:)
  func endActivity(arguments: Array<Any>?) {
    guard #available(iOS 16.1, *) else { return }
    
    guard let arguments = arguments,
          let params = arguments[0] as? [String: Any],
          let activityId = params["id"] as? String else {
      NSLog("[ERROR] Invalid arguments for endActivity")
      return
    }
    
    Task {
      for activity in Activity<MyActivityAttributes>.activities {
        if activity.id == activityId {
          await activity.end(dismissalPolicy: .immediate)
          NSLog("[INFO] Activity \(activityId) ended")
          return
        }
      }
      
      NSLog("[ERROR] Activity with ID \(activityId) not found")
    }
  }
  
  @objc(example:)
  func example(arguments: Array<Any>?) -> String? {
    guard let arguments = arguments, let params = arguments[0] as? [String: Any] else { return nil }
    return params["hello"] as? String
  }
  
  @objc public var exampleProp: String {
     get { 
        return "Titanium rocks!"
     }
     set {
        self.replaceValue(newValue, forKey: "exampleProp", notification: false)
     }
  }
}