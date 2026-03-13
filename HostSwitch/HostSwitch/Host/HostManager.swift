//
//  HostManager.swift
//  HostSwitch
//
//  Created by Ariel Hernandez on 3/13/26.
//

import Foundation

// High-level API for managing user-defined host files.
//
// `HostManager` delegates persistence to a `HostFileStoring` implementation so the app can swap storage
// strategies (and OS-specific behavior) without changing the UI layer.
final class HostManager {
    
    private let store: HostFileStoring

    // Creates a manager backed by the provided store.
    init(store: HostFileStoring) {
        self.store = store
    }

    // Creates a manager backed by the default file-system store.
    //
    // - Parameters:
    //   - rootDirectoryURL: Optional custom directory for host files. If `nil`, uses Application Support.
    //   - fileManager: The file manager used to resolve the default directory and perform I/O.
    // - Throws: `HostManagementError` if the default directory cannot be resolved.
    convenience init(rootDirectoryURL: URL? = nil, fileManager: FileManager = .default) throws {
        let resolvedRoot = try rootDirectoryURL ?? FileSystemHostFileStore.getApplicationSupportPath(fileManager: fileManager)
        self.init(store: FileSystemHostFileStore(rootDirectoryURL: resolvedRoot, fileManager: fileManager))
    }

    // Lists all defined host files (metadata only).
    //
    // - Returns: A list of host files with `contents == nil`.
    func list() throws -> [HostFile] {
        try store.list()
    }

    // Loads a host file including its contents.
    //
    // - Parameter name: The host file name (with or without the `.hosts` extension).
    // - Returns: A `HostFile` with `contents` populated.
    func get(name: String) throws -> HostFile {
        try store.get(name: name)
    }

    // Creates a new host file.
    //
    // - Parameters:
    //   - name: The host file name (with or without the `.hosts` extension).
    //   - contents: The file contents.
    // - Returns: The newly created host file.
    @discardableResult
    func save(name: String, contents: String) throws -> HostFile {
        try store.save(name: name, contents: contents)
    }

    // Deletes a host file and removes it from the index.
    //
    // - Parameter name: The host file identifier.
    func delete(name: String) throws {
        try store.delete(name: name)
    }
}
