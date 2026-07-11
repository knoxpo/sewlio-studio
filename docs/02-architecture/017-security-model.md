# Architecture
## ARCH-017 Security Model

**Document ID:** ARCH-017  
**Title:** Security Model  
**Version:** 1.0.0  
**Status:** Foundation  
**Priority:** Critical

**Owner:** Security Platform Team

---

# Purpose

The Security Model defines how Sewlio Studio protects user projects, plugins, AI actions, storage, exports, credentials, and runtime integrity.

Security is not a feature.

Security is a platform layer.

---

# Core Principle

Every external actor must pass through the Security Gateway.

```text
User
Plugin
AI
Automation
Collaboration

↓

Security Gateway

↓

Command Bus

↓

Document
```

No actor may access or mutate project state directly.

---

# Security Goals

The platform shall protect:

- User projects
- Local files
- Project integrity
- Plugin execution
- AI context
- Credentials
- Export files
- Recovery data
- Workspace data
- Future collaboration data

---

# Trust Boundaries

```text
Trusted Core
    Rust Kernel
    Command Bus
    Event Bus
    Document Manager
    Security Gateway

Semi-Trusted
    Flutter UI
    Built-in plugins
    Local AI tools

Untrusted
    Third-party plugins
    Imported files
    External storage
    Cloud AI providers
    Collaboration clients
```

Anything outside the Rust core is treated as untrusted by default.

---

# Security Gateway

The Security Gateway is the single enforcement layer.

Responsibilities:

- Permission checks
- Policy checks
- Command authorization
- Plugin sandbox enforcement
- AI context filtering
- Audit logging
- Sensitive operation confirmation

```text
Request

↓

Security Gateway

↓

Permission Engine

↓

Policy Engine

↓

Audit Engine

↓

Command Bus
```

---

# Permission Engine

Permissions are capability-based.

Examples:

```text
read_project
modify_project
export_project
import_file
access_files
access_network
access_clipboard
register_plugin
execute_ai_tool
read_thread_library
read_machine_profile
```

Permissions are explicit.

No implicit escalation.

---

# Policy Engine

Policies define whether an action is allowed.

Example policies:

```text
AI may not delete objects without confirmation.

Unsigned plugins may not access network.

Plugins may not access arbitrary files.

Cloud AI may only receive approved context.

Exports may only write to user-approved destinations.
```

Policies may be:

- Application-level
- Workspace-level
- Project-level
- Organization-level future
- Plugin-level
- AI-session-level

---

# Command Authorization

Every command is checked before execution.

```text
Command

↓

Schema Validation

↓

Permission Check

↓

Policy Check

↓

Risk Classification

↓

Execute / Reject / Ask Confirmation
```

High-risk commands require user confirmation.

Examples:

- Delete project
- Delete layer
- Batch replace
- Export outside project folder
- Plugin installation
- Cloud AI request
- Project migration
- Recovery overwrite

---

# Risk Levels

```text
Low
Read-only, explain, inspect

Medium
Modify selection, change visual settings

High
Delete, overwrite, export, migrate, install plugin

Critical
Access secrets, network upload, destructive batch operation
```

---

# Plugin Security

Plugins run in a sandbox.

Plugins may only communicate through:

```text
Plugin API
Commands
Filtered Events
Extension Points
Resource APIs
```

Plugins may not access:

```text
Raw document memory
Internal databases
Other plugin storage
Secrets
Unapproved files
Private Rust structs
```

---

# Plugin Permissions

Plugins must declare permissions in `manifest.json`.

Example:

```json
{
  "permissions": [
    "read_project",
    "register_export_generator",
    "access_files"
  ]
}
```

User approval is required before enabling sensitive permissions.

---

# Plugin Trust Levels

```text
Built-in
Verified Publisher
User Installed
Unsigned
Development
```

Unsigned and development plugins receive stricter defaults.

---

# AI Security

AI is never allowed to mutate the document directly.

```text
AI

↓

Tool Call

↓

Permission Check

↓

Command Proposal

↓

User Confirmation if Required

↓

Command Bus
```

AI receives structured context only.

It never receives raw runtime memory.

---

# AI Context Filtering

Before context reaches a model:

```text
Project Data

↓

Context Builder

↓

Security Filter

↓

Approved Context Pack

↓

Model
```

Cloud providers receive only user-approved context.

Sensitive data is removed.

---

# AI Execution Modes

```text
Disabled

Read Only

Suggest Only

Assisted

Autonomous Restricted
```

Default mode should be **Suggest Only**.

---

# File Security

Imported files are untrusted.

Before import:

```text
File

↓

Signature Detection

↓

Size Check

↓

Parser Sandbox

↓

Validation

↓

Import IR
```

Importers must never execute embedded code.

Blocked:

- SVG scripts
- External network references
- Archive traversal
- Malformed package paths
- Unsafe plugin payloads

---

# Project Security

Opening a project requires validation:

```text
Manifest

↓

Schema Version

↓

Checksums

↓

Database Integrity

↓

Asset Integrity

↓

Plugin References

↓

Open
```

Corrupt projects open only in safe recovery mode where possible.

---

# Storage Security

Projects remain local-first.

No hidden uploads.

No automatic telemetry.

No cloud sync without explicit configuration.

Storage validates:

- manifest
- checksums
- schema versions
- recovery journals
- asset references

---

# Secure Store

Secrets are never stored in `.swl`.

Secrets include:

- AI API keys
- OAuth tokens
- plugin tokens
- cloud credentials
- license keys future

Use OS secure storage:

```text
macOS: Keychain
iOS: Keychain
Windows: Credential Manager
Android: Keystore
Linux: Secret Service
```

---

# Export Security

Export never modifies the project.

Export writes only to user-approved locations.

Partial exports are cleaned up.

```text
Export

↓

Validate Destination

↓

Write Temporary File

↓

Verify

↓

Finalize
```

---

# Recovery Security

Recovery must never overwrite the original project automatically.

```text
Recovery Candidate

↓

Validation

↓

Preview

↓

User Approval

↓

Restore Copy
```

Repair always creates a backup first.

---

# Event Security

Events are filtered before leaving the trusted core.

Plugins and AI receive only public or permission-approved events.

Sensitive internal events remain private.

---

# Audit Logging

Security-sensitive actions are recorded.

Examples:

```text
Plugin installed
Plugin permission changed
AI tool executed
Cloud model called
Project migrated
Recovery restored
Export completed
Security warning dismissed
```

Audit logs should avoid storing secrets.

---

# Network Security

Network access is disabled by default except for explicitly enabled features.

Allowed only through approved services:

- AI provider
- plugin marketplace
- update checker
- optional sync provider
- future collaboration service

Plugins require explicit network permission.

---

# Privacy Defaults

Default configuration:

```text
Telemetry: Off
Cloud sync: Off
Cloud AI: Off
Plugin network: Off
Crash reports: Off
Local projects: On
Offline mode: On
```

---

# Encryption

Future support:

- encrypted projects
- encrypted backups
- encrypted workspace data
- encrypted collaboration
- signed plugins

Recommended algorithm:

```text
AES-256-GCM
```

Key storage must use Secure Store.

---

# Security Diagnostics

Security diagnostics include:

```text
Permission denied
Plugin blocked
Unsafe import rejected
Cloud context blocked
Invalid project checksum
Unsigned plugin warning
Policy violation
```

Diagnostics must be understandable and actionable.

---

# Performance Targets

```text
Permission check: <2 ms
Policy check: <5 ms
Command authorization: <10 ms
Context filtering: <50 ms
Project manifest validation: <100 ms
```

Security must not block UI unnecessarily.

Heavy validation runs on worker threads.

---

# Testing

Security requires:

- permission tests
- policy tests
- sandbox tests
- malicious import tests
- corrupt project tests
- AI context filtering tests
- plugin escalation tests
- secure storage tests
- audit log tests
- export destination tests

Fault injection is mandatory.

---

# AI Agent Rules

Agents working on security-sensitive code must not:

- bypass the Security Gateway
- add direct document access
- store secrets in project files
- allow plugins raw memory access
- send full project data to AI providers
- introduce hidden network calls
- skip audit logging for sensitive actions

---

# Architectural Constraints

1. Security Gateway is mandatory for all external actors.
2. Commands are authorized before execution.
3. Plugins are sandboxed.
4. AI uses tools and commands only.
5. Secrets never enter project files.
6. Imported files are untrusted.
7. Cloud features are opt-in.
8. Events are filtered for external subscribers.
9. Recovery never overwrites originals automatically.
10. All security-sensitive actions are auditable.

---

# Future Enhancements

- Enterprise policy engine
- Signed commands
- Signed projects
- Plugin certificate authority
- Zero-knowledge cloud sync
- End-to-end encrypted collaboration
- Project-level encryption
- Tamper-evident audit logs
- Security dashboard
- Organization trust policies

---

# Acceptance Criteria

The Security Model is complete when:

✓ All external actors pass through the Security Gateway.

✓ Commands require authorization.

✓ Plugins are sandboxed and permissioned.

✓ AI context is filtered and permission-controlled.

✓ Secrets are stored only in OS secure storage.

✓ Project files are validated before opening.

✓ Imports are sandboxed and safe.

✓ Cloud/network access is opt-in.

✓ Security-sensitive actions are audited.

✓ No subsystem can bypass security enforcement.
