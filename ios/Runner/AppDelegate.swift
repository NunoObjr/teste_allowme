import UIKit
import Flutter
import BackgroundTasks

import AllowMeSDKHomolog
let ALLOWME_API_KEY = "KB3KByTN4CjXGOjy0MRO0F8c1R5CrZrXlD5rsTwi"

var methodChannel: FlutterMethodChannel?

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, AllowMeBiometryDelegate {
  var allowMe: AllowMe?
  
  override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    debugPrint("application")
    
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    methodChannel = FlutterMethodChannel(name: "br.com.samples.allowme/sdk",
                                         binaryMessenger: controller.binaryMessenger)
    
    do {
      let allowMe = try AllowMe.getInstance(withApiKey: ALLOWME_API_KEY)
      allowMe.setup(completion: { error in
        print("Setup error: \(String(describing: error?.localizedDescription))")
      })
      
      let error = allowMe.start()
      print("Start error: \(String(describing: error?.localizedDescription))")
      
      self.allowMe = allowMe
    } catch let initError {
      print("Erro ao inicializar: \(initError.localizedDescription)")
    }
    
    methodChannel?.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in

      if self.allowMe != nil {
        if (call.method == "collect") {
          self.allowMe?.collect(onSuccess: { (collect) in
            result("Collect Success: \(collect)")
          }, onError: { (error) in
            result("collect error: \(String(describing: error?.localizedDescription))")
          })
          return
        } else if (call.method == "start") {
          result("'start' was called when starting the app on AppDelegate!")
          return
        } else if (call.method == "setup") {
          
          self.allowMe?.setup { (error) in
            if error != nil {
              result("Setup Error: \(error?.localizedDescription ?? "nil")")
            } else {
              result("Setup Success!!")
            }
          }
          return
        } else if (call.method == "biometry") {
          do {
            let config = AllowMeBiometryConfig()
            try self.allowMe?.startBiometry(viewController: controller,
                                            delegate: self, config: config)
            
          } catch let initError {
            result("Erro ao inicializar: \(initError.localizedDescription)")
          }
          return
        } else if (call.method == "addPerson") {
          let adddress = AddressModel(street: "Rua",
                                      number: "000",
                                      neighbourhood: "Bairro",
                                      city: "Cidade",
                                      state: "AA",
                                      zipCode: "00000000")
          
          let person = PersonModel(name: "Nome",
                                   nationalId: "00000000000",
                                   address: adddress)
          
          self.allowMe?.addPerson(person: person, completion: { (error) in
            if error == nil {
              result("AddPerson Success!")
            } else {
              result("addPerson error: \(String(describing: error?.localizedDescription))")
            }
          })
          return
        }
      }
      result(FlutterMethodNotImplemented)
      return
    })
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  public override func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    try? AllowMe.getInstance().application(application, performFetchWithCompletionHandler: completionHandler)
  }
  
  func biometryDidFinish(biometryObject: AllowMeBiometryResult?, error: Error?) {
    print("Payload: \(String(describing: biometryObject?.payload))")
    print("Images: \(String(describing: biometryObject?.images))")
    print("Biometrics Error: \(String(describing: error?.localizedDescription))")
    let result = "Payload: \(String(describing: biometryObject?.payload)) | Images: \(String(describing: biometryObject?.images)) | Biometrics Error: \(String(describing: error?.localizedDescription))"
    methodChannel?.invokeMethod("didReceiveBiometry", arguments: result)
  }
}
