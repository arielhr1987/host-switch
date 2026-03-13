# Host management

This folder contains the core types for managing:

- **Host files**: user-created host files stored inside the app’s container (Application Support).
- **System hosts**: the OS hosts file (macOS default: `/etc/hosts`), read-only unless a privileged writer is injected.

## Host files

- `HostFile` holds metadata + optional `contents` (so lists can be metadata-only).
- `HostManager` provides `list/get/create/save/delete`.
- `FileSystemHostFileStore` backs `HostManager` using a directory you provide.
  - Files are stored as `<name>.hosts`
  - Files are discovered by scanning the directory for the `.hosts` extension

Suggested default directory:

- `FileSystemHostFileStore.getApplicationSupportPath()`

## System hosts (OS file)

- `FileSystemSystemHostsManager` can always **read** `systemHostsURL`.
- Writing requires a `privilegedWrite` handler:
  - Without it, `writeSystemHosts` throws `HostManagementError.writeRequiresPrivileges`.
  - Later, you can plug in a privileged helper / authorization flow (this is where multi–macOS-version support typically lives).
