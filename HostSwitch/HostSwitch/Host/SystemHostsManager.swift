//
//  SystemHostsManager.swift
//  HostSwitch
//
//  Created by Ariel Hernandez on 3/13/26.
//

import Foundation

// An interface for reading and (optionally) writing the system hosts file.
//
// Writing the system hosts file generally requires elevated privileges on macOS. HostSwitch injects a
// privileged writer so the rest of the app can remain version-agnostic.
protocol SystemHostsManaging {
    // The URL of the system hosts file.
    var systemHostsURL: URL { get }

    // Reads the system hosts file contents.
    func readSystemHosts() throws -> String

    // Writes the system hosts file contents.
    func writeSystemHosts(_ contents: String) throws
}

// Provides the default system hosts file location on macOS.
struct MacOSSystemHostsLocationProvider: Sendable {
    // The default macOS hosts file path as a file URL.
    var systemHostsURL: URL {
        // /etc/hosts is commonly a symlink to /private/etc/hosts on macOS.
        URL(fileURLWithPath: "/etc/hosts", isDirectory: false)
    }
}

// File-system implementation of `SystemHostsManaging`.
//
// Reading is performed directly from `systemHostsURL`. Writing is delegated to an injected privileged
// write handler so the privilege elevation mechanism can vary by macOS version.
final class FileSystemSystemHostsManager: SystemHostsManaging {
    // A callback that performs a privileged write to `url` with `data`.
    typealias PrivilegedWriteHandler = @Sendable (_ url: URL, _ data: Data) throws -> Void

    // The URL of the system hosts file.
    let systemHostsURL: URL
    private let fileManager: FileManager
    private let privilegedWrite: PrivilegedWriteHandler?

    // Creates a system hosts manager.
    //
    // - Parameters:
    //   - systemHostsURL: The system hosts file location.
    //   - fileManager: Reserved for future use (e.g., attribute checks, existence checks).
    //   - privilegedWrite: Handler used to write the system hosts file with elevated privileges.
    init(
        systemHostsURL: URL = MacOSSystemHostsLocationProvider().systemHostsURL,
        fileManager: FileManager = .default,
        privilegedWrite: PrivilegedWriteHandler? = nil
    ) {
        self.systemHostsURL = systemHostsURL
        self.fileManager = fileManager
        self.privilegedWrite = privilegedWrite
    }

    // Reads the system hosts file.
    func readSystemHosts() throws -> String {
        do {
            let data = try Data(contentsOf: systemHostsURL)
            return String(decoding: data, as: UTF8.self)
        } catch {
            throw HostManagementError.readFailed(systemHostsURL, underlying: error)
        }
    }

    // Writes the system hosts file using the injected privileged writer.
    //
    // - Throws: `HostManagementError.writeRequiresPrivileges` when no privileged writer is configured.
    func writeSystemHosts(_ contents: String) throws {
        guard let privilegedWrite else {
            throw HostManagementError.writeRequiresPrivileges(systemHostsURL)
        }

        let data = Data(contents.utf8)
        do {
            try privilegedWrite(systemHostsURL, data)
        } catch {
            throw HostManagementError.writeFailed(systemHostsURL, underlying: error)
        }
    }
}
