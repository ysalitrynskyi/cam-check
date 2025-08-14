import Cocoa
import AVFoundation

// The @main attribute tells the system that this class is the entry point.
// This is the correct way to start an AppKit application programmatically.
@main
class AppDelegate: NSObject, NSApplicationDelegate {

    // A strong reference to the status item is crucial to prevent it from disappearing.
    private var statusItem: NSStatusItem!
    private var captureSession: AVCaptureSession?
    
    // A strong reference to the custom About window to prevent it from closing immediately.
    private var aboutWindow: NSWindow?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        // Find and close any main window if the project accidentally created one.
        if let window = NSApplication.shared.windows.first {
            print("Found an unexpected window. Closing it to run as a menu bar app.")
            window.close()
        }
        
        // Create the status item in the system menu bar.
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        // Use a guard to safely unwrap the button. If this fails, the app will print an error.
        guard let button = statusItem.button else {
            print("FATAL ERROR: statusItem.button is nil. The status bar item could not be created.")
            return
        }
        
        // Configure the button's icon.
        if let iconImage = NSImage(named: "MenuBarIcon") {
            print("Successfully loaded 'MenuBarIcon' from assets.")
            
            // Set the desired size for the icon.
            iconImage.size = NSSize(width: 18, height: 18)
            
            // Ensure 'isTemplate' is true so macOS can style it for light/dark mode.
            iconImage.isTemplate = true
            
            button.image = iconImage
        } else {
            // If the image is missing, it will show a star as a fallback.
            print("Warning: MenuBarIcon not found. Using fallback system icon 'star.fill'.")
            button.image = NSImage(systemSymbolName: "star.fill", accessibilityDescription: "CamCheck")
        }
        
        // Create and assign the menu.
        let menu = NSMenu()
        
        // Add the new "About" menu item.
        menu.addItem(withTitle: "About CamCheck", action: #selector(showAboutPanel), keyEquivalent: "")
        menu.addItem(NSMenuItem.separator())
        
        menu.addItem(withTitle: "Test Camera Light", action: #selector(testCamera), keyEquivalent: "")
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        statusItem.menu = menu
    }
    
    // **UPDATED**: This function creates and displays our custom "About" window.
    @objc func showAboutPanel() {
        // If the window already exists, just bring it to the front.
        if let aboutWindow = aboutWindow, aboutWindow.isVisible {
            aboutWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        // Create the window with a new, taller height
        aboutWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 300),
            styleMask: [.titled, .closable, .fullSizeContentView], // Use fullSizeContentView for modern look
            backing: .buffered,
            defer: false
        )
        
        // Window properties
        aboutWindow?.center()
        aboutWindow?.title = "" // Hide title from title bar
        aboutWindow?.titlebarAppearsTransparent = true // Make title bar transparent
        aboutWindow?.isMovableByWindowBackground = true // Allow dragging from anywhere
        aboutWindow?.isReleasedWhenClosed = false

        // Create a visual effect view for a modern, blurred background
        let visualEffectView = NSVisualEffectView()
        visualEffectView.blendingMode = .behindWindow
        visualEffectView.state = .active
        visualEffectView.material = .sidebar
        
        // Create the main view that will hold all the content
        let contentView = visualEffectView
        
        // 1. App Icon
        let appIcon = NSImageView(frame: NSRect(x: 174, y: 190, width: 72, height: 72))
        appIcon.image = NSImage(named: "AppIcon") // Assumes you have an AppIcon set in your assets
        contentView.addSubview(appIcon)

        // 2. App Name Label
        let appNameLabel = NSTextField(labelWithString: "CamCheck")
        appNameLabel.font = NSFont.boldSystemFont(ofSize: 24)
        appNameLabel.alignment = .center
        appNameLabel.frame = NSRect(x: 20, y: 155, width: 380, height: 30)
        contentView.addSubview(appNameLabel)

        // 3. Version Label
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let versionLabel = NSTextField(labelWithString: "Version \(version)")
        versionLabel.font = NSFont.systemFont(ofSize: 12)
        versionLabel.textColor = .secondaryLabelColor
        versionLabel.alignment = .center
        versionLabel.frame = NSRect(x: 20, y: 135, width: 380, height: 20)
        contentView.addSubview(versionLabel)

        // 4. Description Label with adjusted height and position
        let descriptionLabel = NSTextField(wrappingLabelWithString: "CamCheck is a simple and privacy-focused utility to quickly test your Mac's camera indicator light, ensuring your camera is functioning correctly and is not active when it shouldn't be.")
        descriptionLabel.font = NSFont.systemFont(ofSize: 13)
        descriptionLabel.alignment = .center
        descriptionLabel.frame = NSRect(x: 40, y: 50, width: 340, height: 80)
        contentView.addSubview(descriptionLabel)
        
        // 5. GitHub Link Button with adjusted position for more spacing
        let githubButton = NSButton(title: "View on GitHub", target: self, action: #selector(openGithubLink))
        githubButton.bezelStyle = .inline
        githubButton.isBordered = false
        let attributedString = NSMutableAttributedString(string: "View on GitHub")
        attributedString.addAttribute(.link, value: "https://github.com/ysalitrynskyi/cam-check", range: NSRange(location: 0, length: attributedString.length))
        attributedString.addAttribute(.font, value: NSFont.systemFont(ofSize: 12), range: NSRange(location: 0, length: attributedString.length))
        githubButton.attributedTitle = attributedString
        githubButton.frame = NSRect(x: 20, y: 35, width: 380, height: 20)
        contentView.addSubview(githubButton)

        // 6. Copyright Label (with your name and company) with adjusted position and year
        let copyrightLabel = NSTextField(labelWithString: "Copyright © 2025 Yevhen Salitrynskyi (YS Progress Inc.)")
        copyrightLabel.font = NSFont.systemFont(ofSize: 10)
        copyrightLabel.textColor = .tertiaryLabelColor
        copyrightLabel.alignment = .center
        copyrightLabel.frame = NSRect(x: 20, y: 15, width: 380, height: 20)
        contentView.addSubview(copyrightLabel)

        // Set the content view and show the window
        aboutWindow?.contentView = contentView
        aboutWindow?.makeKeyAndOrderFront(nil)
        
        // Bring the app to the foreground to make sure the window is visible
        NSApp.activate(ignoringOtherApps: true)
    }
    
    // This function is called when the GitHub button is clicked.
    @objc func openGithubLink() {
        if let url = URL(string: "https://github.com/ysalitrynskyi/cam-check") {
            NSWorkspace.shared.open(url)
        }
    }
    
    @objc func testCamera() {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let videoDevice = AVCaptureDevice.default(for: .video) else {
                DispatchQueue.main.async { self.showAlert(title: "Error", message: "No camera device was found.") }
                return
            }
            
            do {
                let videoInput = try AVCaptureDeviceInput(device: videoDevice)
                let videoOutput = AVCaptureVideoDataOutput()
                
                self.captureSession = AVCaptureSession()
                
                if self.captureSession!.canAddInput(videoInput) && self.captureSession!.canAddOutput(videoOutput) {
                    self.captureSession!.addInput(videoInput)
                    self.captureSession!.addOutput(videoOutput)
                    self.captureSession!.startRunning()
                    
                    // Turn off after 5 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                        self.captureSession?.stopRunning()
                        self.captureSession = nil
                    }
                }
            } catch {
                DispatchQueue.main.async { self.showAlert(title: "Error", message: "Failed to access camera.") }
            }
        }
    }

    func showAlert(title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.runModal()
    }
}
