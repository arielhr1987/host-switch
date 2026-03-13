//
//  HostManagementError.swift
//  HostSwitch
//
//  Created by Ariel Hernandez on 3/13/26.
//

import Foundation

// Errors produced by the HostSwitch host-management module.
enum HostManagementError: Error, LocalizedError, Sendable {
    // The provided host file name is invalid (for example, empty after trimming whitespace).
    case invalidHostFileName(String)

    // A host file entry for the provided identifier does not exist.
    case hostFileNotFound(String)

    // Creating the storage directory failed.
    case directoryCreationFailed(URL, underlying: Error)

    // Reading a file failed.
    case readFailed(URL, underlying: Error)

    // Writing a file failed.
    case writeFailed(URL, underlying: Error)

    // Deleting a file failed.
    case deleteFailed(URL, underlying: Error)

    // Encoding metadata failed.
    case encodingFailed(underlying: Error)

    // Decoding metadata failed.
    case decodingFailed(URL, underlying: Error)

    // The requested operation requires elevated privileges.
    case writeRequiresPrivileges(URL)

    var errorDescription: String? {
        switch self {
        case .invalidHostFileName(let name):
            return "Invalid host file name: \(name)"
        case .hostFileNotFound:
            return "Host file not found."
        case .directoryCreationFailed(let url, _):
            return "Unable to create directory at \(url.path)."
        case .readFailed(let url, _):
            return "Unable to read hosts file at \(url.path)."
        case .writeFailed(let url, _):
            return "Unable to write hosts file at \(url.path)."
        case .deleteFailed(let url, _):
            return "Unable to delete hosts file at \(url.path)."
        case .encodingFailed:
            return "Unable to encode hosts metadata."
        case .decodingFailed:
            return "Unable to decode hosts metadata."
        case .writeRequiresPrivileges(let url):
            return "Writing to \(url.path) requires elevated privileges."
        }
    }
}
