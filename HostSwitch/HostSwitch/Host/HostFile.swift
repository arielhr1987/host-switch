//
//  HostFile.swift
//  HostSwitch
//
//  Created by Ariel Hernandez on 3/13/26.
//

import Foundation

// A user-defined hosts file managed by HostSwitch.
//
// A `HostFile` can be listed with metadata only (`contents == nil`) or loaded with its full text contents.
struct HostFile: Identifiable, Hashable, Sendable {
    // Stable identifier for the host file entry.
    let id: String

    // Display name shown in the UI.
    var name: String

    // The on-disk location for this host file’s contents.
    var fileURL: URL

    // The timestamp when the host file entry was created.
    var createdAt: Date

    // The timestamp when the host file entry was last updated.
    var updatedAt: Date

    // The file size, when available.
    var fileSizeBytes: Int64?

    // The text contents of the host file.
    //
    // This value may be `nil` when the instance was produced by a metadata-only listing.
    var contents: String?

    // The filename portion of `fileURL`.
    var filename: String { fileURL.lastPathComponent }
}
