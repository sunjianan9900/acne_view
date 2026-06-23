import Cocoa
import FlutterMacOS
import AVFoundation

public class AcneUvcCameraMacosPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?
  private var cameraManager: UvcCameraManager?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = AcneUvcCameraMacosPlugin()
    let channel = FlutterMethodChannel(
      name: "acne_uvc_camera_macos",
      binaryMessenger: registrar.messenger
    )
    registrar.addMethodCallDelegate(instance, channel: channel)

    let eventChannel = FlutterEventChannel(
      name: "acne_uvc_camera_macos/events",
      binaryMessenger: registrar.messenger
    )
    eventChannel.setStreamHandler(instance)

    let textureRegistry = registrar.textures
    instance.cameraManager = UvcCameraManager(textureRegistry: textureRegistry)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let manager = cameraManager else {
      result(FlutterError(code: "unavailable", message: "Camera manager not ready", details: nil))
      return
    }

    switch call.method {
    case "isSupported":
      result(true)
    case "listDevices":
      result(manager.listDevices())
    case "initialize":
      let args = call.arguments as? [String: Any]
      let preferExternal = args?["preferExternal"] as? Bool ?? true
      let deviceId = args?["deviceId"] as? String
      manager.initialize(preferExternal: preferExternal, deviceId: deviceId) { textureId, error in
        if let error = error {
          result(FlutterError(code: "init_failed", message: error.localizedDescription, details: nil))
        } else {
          result(textureId)
        }
      }
    case "dispose":
      manager.dispose()
      result(nil)
    case "takePicture":
      manager.takePicture { path, error in
        if let error = error {
          result(FlutterError(code: "capture_failed", message: error.localizedDescription, details: nil))
        } else {
          result(path)
        }
      }
    case "switchCamera":
      manager.switchCamera { textureId, error in
        if let error = error {
          result(FlutterError(code: "switch_failed", message: error.localizedDescription, details: nil))
        } else {
          result(textureId)
        }
      }
    case "selectDevice":
      let args = call.arguments as? [String: Any]
      guard let deviceId = args?["deviceId"] as? String else {
        result(FlutterError(code: "invalid_args", message: "deviceId is required", details: nil))
        return
      }
      manager.selectDevice(deviceId: deviceId) { textureId, error in
        if let error = error {
          result(FlutterError(code: "select_failed", message: error.localizedDescription, details: nil))
        } else {
          result(textureId)
        }
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    eventSink = events
    cameraManager?.onConnectionChange = { [weak self] event in
      self?.eventSink?(event)
    }
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    cameraManager?.onConnectionChange = nil
    return nil
  }
}

// MARK: - Camera Manager

class UvcCameraManager: NSObject {
  private let textureRegistry: FlutterTextureRegistry
  private var texture: CameraTexture?
  private var captureSession: AVCaptureSession?
  private var photoOutput: AVCapturePhotoOutput?
  private var currentDevice: AVCaptureDevice?
  private var devices: [AVCaptureDevice] = []
  private var preferExternal = true
  private var photoDelegate: PhotoCaptureDelegate?

  var onConnectionChange: ((String) -> Void)?

  init(textureRegistry: FlutterTextureRegistry) {
    self.textureRegistry = textureRegistry
    super.init()
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(deviceConnected),
      name: .AVCaptureDeviceWasConnected,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(deviceDisconnected),
      name: .AVCaptureDeviceWasDisconnected,
      object: nil
    )
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  @objc private func deviceConnected(_ notification: Notification) {
    onConnectionChange?("connected")
    refreshDevices()
  }

  @objc private func deviceDisconnected(_ notification: Notification) {
    onConnectionChange?("disconnected")
    refreshDevices()
  }

  func listDevices() -> [[String: Any]] {
    refreshDevices()
    return devices.map { device in
      [
        "id": device.uniqueID,
        "name": device.localizedName,
        "isExternal": isExternalDevice(device),
      ]
    }
  }

  private func isExternalDevice(_ device: AVCaptureDevice) -> Bool {
    if #available(macOS 14.0, *) {
      return device.deviceType == .external
    }
    return device.deviceType == .externalUnknown
  }

  private func videoDeviceTypes() -> [AVCaptureDevice.DeviceType] {
    if #available(macOS 14.0, *) {
      return [.builtInWideAngleCamera, .external]
    }
    return [.builtInWideAngleCamera, .externalUnknown]
  }

  private func refreshDevices() {
    let session = AVCaptureDevice.DiscoverySession(
      deviceTypes: videoDeviceTypes(),
      mediaType: .video,
      position: .unspecified
    )
    devices = session.devices
  }

  func initialize(preferExternal: Bool, deviceId: String?, completion: @escaping (Int64?, Error?) -> Void) {
    self.preferExternal = preferExternal
    refreshDevices()

    let device: AVCaptureDevice?
    if let deviceId = deviceId {
      device = devices.first(where: { $0.uniqueID == deviceId })
    } else {
      device = selectDevice()
    }

    guard let device = device else {
      completion(nil, NSError(domain: "UvcCamera", code: 1, userInfo: [
        NSLocalizedDescriptionKey: "未找到可用摄像头",
      ]))
      return
    }

    setupSession(device: device, completion: completion)
  }

  private func selectDevice() -> AVCaptureDevice? {
    if preferExternal {
      if let external = devices.first(where: { isExternalDevice($0) }) {
        return external
      }
    }
    if let builtIn = devices.first(where: { !isExternalDevice($0) }) {
      return builtIn
    }
    return devices.first
  }

  private func setupSession(device: AVCaptureDevice, completion: @escaping (Int64?, Error?) -> Void) {
    dispose()

    let session = AVCaptureSession()
    session.sessionPreset = .high

    do {
      let input = try AVCaptureDeviceInput(device: device)
      if session.canAddInput(input) {
        session.addInput(input)
      }

      let output = AVCaptureVideoDataOutput()
      output.videoSettings = [
        kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
      ]
      output.alwaysDiscardsLateVideoFrames = true

      let cameraTexture = CameraTexture(registry: textureRegistry)
      output.setSampleBufferDelegate(cameraTexture, queue: DispatchQueue(label: "camera.frame.queue"))

      if session.canAddOutput(output) {
        session.addOutput(output)
      }

      let photoOut = AVCapturePhotoOutput()
      if session.canAddOutput(photoOut) {
        session.addOutput(photoOut)
      }

      self.captureSession = session
      self.photoOutput = photoOut
      self.currentDevice = device
      self.texture = cameraTexture

      DispatchQueue.global(qos: .userInitiated).async {
        session.startRunning()
        DispatchQueue.main.async {
          completion(cameraTexture.textureId, nil)
        }
      }
    } catch {
      completion(nil, error)
    }
  }

  func switchCamera(completion: @escaping (Int64?, Error?) -> Void) {
    guard devices.count > 1 else {
      completion(texture?.textureId, nil)
      return
    }
    guard let current = currentDevice,
          let idx = devices.firstIndex(of: current) else {
      completion(texture?.textureId, nil)
      return
    }
    let next = devices[(idx + 1) % devices.count]
    setupSession(device: next, completion: completion)
  }

  func selectDevice(deviceId: String, completion: @escaping (Int64?, Error?) -> Void) {
    refreshDevices()
    guard let device = devices.first(where: { $0.uniqueID == deviceId }) else {
      completion(nil, NSError(domain: "UvcCamera", code: 3, userInfo: [
        NSLocalizedDescriptionKey: "未找到指定摄像头",
      ]))
      return
    }
    if currentDevice?.uniqueID == deviceId {
      completion(texture?.textureId, nil)
      return
    }
    setupSession(device: device, completion: completion)
  }

  func takePicture(completion: @escaping (String?, Error?) -> Void) {
    guard let photoOutput = photoOutput else {
      completion(nil, NSError(domain: "UvcCamera", code: 2, userInfo: [
        NSLocalizedDescriptionKey: "相机未初始化",
      ]))
      return
    }

    let settings = AVCapturePhotoSettings()
    let delegate = PhotoCaptureDelegate { [weak self] path, error in
      self?.photoDelegate = nil
      completion(path, error)
    }
    photoDelegate = delegate
    photoOutput.capturePhoto(with: settings, delegate: delegate)
  }

  func dispose() {
    captureSession?.stopRunning()
    captureSession = nil
    photoOutput = nil
    currentDevice = nil
    if let texture = texture {
      textureRegistry.unregisterTexture(texture.textureId)
    }
    texture = nil
  }
}

// MARK: - Flutter Texture

class CameraTexture: NSObject, FlutterTexture, AVCaptureVideoDataOutputSampleBufferDelegate {
  private let registry: FlutterTextureRegistry
  private(set) var textureId: Int64 = 0
  private var latestPixelBuffer: CVPixelBuffer?
  private let lock = NSLock()

  init(registry: FlutterTextureRegistry) {
    self.registry = registry
    super.init()
    textureId = registry.register(self)
  }

  func copyPixelBuffer() -> Unmanaged<CVPixelBuffer>? {
    lock.lock()
    defer { lock.unlock() }
    guard let buffer = latestPixelBuffer else { return nil }
    return Unmanaged.passRetained(buffer)
  }

  func captureOutput(
    _ output: AVCaptureOutput,
    didOutput sampleBuffer: CMSampleBuffer,
    from connection: AVCaptureConnection
  ) {
    guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
    lock.lock()
    latestPixelBuffer = pixelBuffer
    lock.unlock()
    registry.textureFrameAvailable(textureId)
  }
}

// MARK: - Photo Delegate

class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
  private let completion: (String?, Error?) -> Void

  init(completion: @escaping (String?, Error?) -> Void) {
    self.completion = completion
  }

  func photoOutput(
    _ output: AVCapturePhotoOutput,
    didFinishProcessingPhoto photo: AVCapturePhoto,
    error: Error?
  ) {
    if let error = error {
      completion(nil, error)
      return
    }

    guard let data = photo.fileDataRepresentation() else {
      completion(nil, NSError(domain: "UvcCamera", code: 3, userInfo: [
        NSLocalizedDescriptionKey: "无法获取照片数据",
      ]))
      return
    }

    let fileName = "uvc_\(Int(Date().timeIntervalSince1970 * 1000)).jpg"
    let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
    do {
      try data.write(to: url)
      completion(url.path, nil)
    } catch {
      completion(nil, error)
    }
  }
}
