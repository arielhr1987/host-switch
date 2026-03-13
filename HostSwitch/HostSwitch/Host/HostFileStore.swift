//
//  HostFileStore.swift
//  HostSwitch
//
//  Created by Ariel Hernandez on 3/13/26.
//

import Foundation

// A persistence interface for storing and retrieving host files.
//
// This abstraction exists so HostSwitch can support alternate storage backends or OS-specific behavior
// without changing callers.
protocol HostFileStoring {
    // Lists all known host files.
    func list() throws -> [HostFile]

    // Loads a host file and its contents.
    func get(name: String) throws -> HostFile

    // Saves a host file. Creates it if it does not exist.
    @discardableResult func save(name: String, contents: String) throws -> HostFile

    // Deletes an existing host file.
    func delete(name: String) throws

    // Renames an existing host file.
    @discardableResult func rename(from: String, to: String) throws -> HostFile
}

// File-system implementation of `HostFileStoring`.
//
// Layout:
// - Each host file’s contents are stored as `<filename>.hosts` in the same directory.
final class FileSystemHostFileStore: HostFileStoring {

    // Path to the directory
    private let directoryURL: URL
    
    // File manager
    private let fileManager: FileManager

    // Returns the default Application Support directory where HostSwitch stores user-defined host files.
    //
    // The directory is under Application Support and is namespaced by the app’s bundle identifier:
    // `~/Library/Application Support/<bundle-id>/hosts/`
    //
    // - Parameters:
    //   - fileManager: The file manager used to resolve the Application Support directory.
    //   - bundleIdentifier: Overrides the bundle identifier used to namespace the folder.
    // - Returns: The directory URL (not guaranteed to already exist on disk).
    static func getApplicationSupportPath(
        fileManager: FileManager = .default,
        bundleIdentifier: String? = Bundle.main.bundleIdentifier
    ) throws -> URL {
        let base = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )

        let bundleID = (bundleIdentifier?.isEmpty == false) ? bundleIdentifier! : "HostSwitch"
        return base
            .appendingPathComponent(bundleID, isDirectory: true)
            .appendingPathComponent("hosts", isDirectory: true)
    }

    // Creates a store that reads and writes inside `directoryURL`.
    //
    // - Parameters:
    //   - rootDirectoryURL: The directory containing `index.json` and the `.hosts` files.
    //   - fileManager: The file manager used for I/O.
    init(rootDirectoryURL: URL, fileManager: FileManager = .default) {
        self.directoryURL = rootDirectoryURL
        self.fileManager = fileManager
    }

    private func normalizedFilename(_ name: String) throws -> String {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            throw HostManagementError.invalidHostFileName(name)
        }

        if trimmedName.lowercased().hasSuffix(".hosts") {
            return trimmedName
        }

        return "\(trimmedName).hosts"
    }

    // Returns the root directory ensuring the directory exists.
    private func getDirectory() throws -> URL {

        if !fileManager.fileExists(atPath: directoryURL.path) {
            do {
                try fileManager.createDirectory(
                    at: directoryURL,
                    withIntermediateDirectories: true
                )
            } catch {
                throw HostManagementError.directoryCreationFailed(
                    directoryURL,
                    underlying: error
                )
            }
        }

        return directoryURL
    }

    // Lists host files by scanning the directory for `.hosts` files.
    func list() throws -> [HostFile] {
        let dir = try getDirectory()

        //Read the files from directory
        let urls = try fileManager.contentsOfDirectory(
            at: dir,
            includingPropertiesForKeys: [.creationDateKey, .contentModificationDateKey, .fileSizeKey],
            options: [.skipsHiddenFiles]
        )

        return try urls
            .filter { $0.pathExtension == "hosts" }
            .compactMap { try makeHostFile(from: $0, contents: nil) }
    }

    // Loads a host file by resolving its filename.
    //
    // - Parameters:
    //      - name: The host filename
    func get(name: String) throws -> HostFile {
        let dir = try getDirectory()

        let filename = try normalizedFilename(name)
        let file = dir.appendingPathComponent(filename, isDirectory: false)

        // Check if the file exists
        guard fileManager.fileExists(atPath: file.path) else {
            throw HostManagementError.hostFileNotFound(filename)
        }

        // Read the file and create the HostFile from it
        do {
            let data = try Data(contentsOf: file)
            let contents = String(decoding: data, as: UTF8.self)
            return try makeHostFile(from: file, contents: contents)
        } catch {
            throw HostManagementError.readFailed(file, underlying: error)
        }
    }

    // Saves the `.hosts` contents.
    //
    // - Parameters:
    //      - name: The host file name
    //      - contents: The hosts file contents
    @discardableResult
    func save(name: String, contents: String) throws -> HostFile {
        let filename = try normalizedFilename(name)

        let directory = try getDirectory()

        let fileURL = directory.appendingPathComponent(filename, isDirectory: false)

        guard let data = contents.data(using: .utf8) else {
            throw HostManagementError.writeFailed(fileURL, underlying: CocoaError(.fileWriteUnknown))
        }

        // Write data to file, throw error on failure.
        do {
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            throw HostManagementError.writeFailed(fileURL, underlying: error)
        }

        return try makeHostFile(from: fileURL, contents: contents)
    }

    // Deletes a host file’s `.hosts` file.
    //
    // - Parameters:
    //      - name: The host file to delete
    func delete(name: String) throws {
        let rootDirectoryURL = try getDirectory()

        let filename = try normalizedFilename(name)
        let url = rootDirectoryURL.appendingPathComponent(filename, isDirectory: false)

        guard fileManager.fileExists(atPath: url.path) else {
            throw HostManagementError.hostFileNotFound(filename)
        }

        do {
            try fileManager.removeItem(at: url)
        } catch {
            throw HostManagementError.deleteFailed(url, underlying: error)
        }
    }

    // Renames a host file on disk.
    //
    // - Parameters:
    //   - from: The current filename.
    //   - to: The new filename.
    @discardableResult
    func rename(from: String, to: String) throws -> HostFile {

        let rootDirectoryURL = try getDirectory()

        let sourceFilename = try normalizedFilename(from)
        let destinationFilename = try normalizedFilename(to)

        let sourceURL = rootDirectoryURL.appendingPathComponent(sourceFilename, isDirectory: false)
        let destinationURL = rootDirectoryURL.appendingPathComponent(destinationFilename, isDirectory: false)

        guard fileManager.fileExists(atPath: sourceURL.path) else {
            throw HostManagementError.hostFileNotFound(sourceFilename)
        }

        do {
            try fileManager.moveItem(at: sourceURL, to: destinationURL)
            return try makeHostFile(from: destinationURL, contents: nil)
        } catch {
            throw HostManagementError.writeFailed(destinationURL, underlying: error)
        }
    }

    // MARK: - Private

    private func makeHostFile(from url: URL, contents: String?) throws -> HostFile {

        let filename = url.lastPathComponent
        let id = filename

        let attributes = try? fileManager.attributesOfItem(atPath: url.path)

        let createdAt = attributes?[.creationDate] as? Date ?? Date()
        let updatedAt = attributes?[.modificationDate] as? Date ?? Date()

        let sizeBytes = (attributes?[.size] as? NSNumber)?.int64Value

        return HostFile(
            id: id,
            name: filename,
            fileURL: url,
            createdAt: createdAt,
            updatedAt: updatedAt,
            fileSizeBytes: sizeBytes,
            contents: contents
        )
    }
}
