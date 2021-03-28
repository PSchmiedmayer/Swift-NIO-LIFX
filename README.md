![Build and Test](https://github.com/PSchmiedmayer/Swift-NIO-LIFX/workflows/Build%20and%20Test/badge.svg)
[![codecov](https://codecov.io/gh/PSchmiedmayer/Swift-NIO-LIFX/branch/develop/graph/badge.svg?token=C0ACXI6FCH)](https://codecov.io/gh/PSchmiedmayer/Swift-NIO-LIFX)

# 💡 SwiftNIO LIFX

Implementation of the LIFX LAN protocol in Swift based on Swift NIO.
You can find a reference of the [LIFX LAN PROTOCOL](https://lan.developer.lifx.com/docs/introduction) on [lan.developer.lifx.com](https://lan.developer.lifx.com/docs/introduction).

## Example

The repository contains a small example command line tool that can be used to discover all devices on a network and toggle them on and off.

## Building

SwiftNIO LIFX is build using [Swift](https://docs.swift.org/swift-book/) and uses [Swift Packages](https://developer.apple.com/documentation/swift_packages). You can learn more about the Swift Package Manager at [swift.org](https://swift.org/package-manager/).

### macOS & Xcode

If you use macOS, you can use [Xcode](https://apps.apple.com/de/app/xcode/id497799835) to open the `Package.swift` file at the root of the repository using Xcode. You can learn more on how to use Swift Packages with Xcode on [developer.apple.com](https://developer.apple.com/documentation/xcode/creating_a_standalone_swift_package_with_xcode).

### Swift Command Line Tool

On [plattforms that support the Swift Package Manager](https://swift.org/platform-support/) you can use the `swift build`, `swift run` and `swift tests` commands to build, run and test the source code.

### Visual Studio Code on any operating system

> ⚠️ Be aware that UDP broadcast currenlty doesn't work in the Docker containers. If you want to test the device discovery you need to run a docker container using the host network or directly run the code on the target plattform.

If you are not using macOS or don't want to use Xcode, you can use [Visual Studio Code](https://code.visualstudio.com) using the [Remote Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) plugin. You must install the latest version of [Visual Studio Code](https://code.visualstudio.com), the latest version of the [Remote Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) plugin and [Docker](https://www.docker.com/products/docker-desktop).

1. Open the folder using Visual Studio Code
2. If you have installed the [Remote Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) plugin [Visual Studio Code](https://code.visualstudio.com) automatically asks you to reopen the folder to develop in a container at the bottom right of the Visual Studio Code window.
3. Press "Reopen in Container" and wait until the docker container is build
4. You can now build the code using the [build keyboard shortcut](https://code.visualstudio.com/docs/getstarted/keybindings#_tasks) and run and test the code within the docker container using the Run and Debug area.
