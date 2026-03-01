# CMPS 405 Operating Systems Lab — PBL Project (Spring 2025)

This repository contains our completed **Project-Based Learning (PBL) assignment** for **Operating Systems Lab (CMPS 405)** at Qatar University. The implementation follows the official project specification and is delivered in **two phases**:

1) Linux administration automation using **Bash shell scripting**, and  
2) a **multithreaded Java client–server system** that dispatches and executes those scripts using a **priority-based** execution model.

> Platform: Ubuntu Server 22.04 LTS (3 VMs: 1 Server + 2 Clients)

---

## What we built

### Phase 1 — System Administration Automation (Bash)
We implemented a set of Bash scripts that automate realistic OS administration workflows with logging, validation, and safe handling of edge cases. The implementation includes:

- **Role-based user and group management**
  - Structured groups for developers / operations / monitoring, including lead/admin roles
  - Automated user creation and supplementary memberships
  - Sudo access configuration for designated lead users

- **Shared directories with ACL-based access control**
  - Shared directory hierarchy for development and operations workflows
  - ACL permissions enforcing full vs read-only access by group

- **Security hardening**
  - SSH key-based authentication for required accounts and disabling password authentication where required
  - Detection/blocking of password-based login attempts for the targeted user
  - Automated security updates (unattended upgrades) with logged status output
  - A configured Message of the Day (MOTD) for SSH sessions

- **Monitoring and auditing**
  - Hourly system metrics logs (CPU/memory, disk I/O, top processes)
  - Service status checks (e.g., MySQL/SSH) with auto-restart attempts and alert logs on failure
  - File activity monitoring for the development directory using `inotifywait` (create/modify/delete + user)

- **MySQL provisioning and auditing**
  - MySQL installation and service verification
  - Least-privilege MySQL user creation and validation
  - Logged user logins and database/table discovery actions for auditability

- **Network connectivity monitoring**
  - Periodic ping monitoring from the server to both clients with timestamped outputs stored securely

### Phase 2 — Priority-Based Script Dispatcher (Java Sockets + Threads)
Building on the Phase 1 scripts, we developed a multithreaded Java client–server system that allows clients to request prioritized execution of the server-side scripts.

Key capabilities:

- **Socket-based client–server communication**
  - The server listens continuously on the required port and supports multiple clients concurrently

- **Connection validation**
  - On new connections, the server verifies client connectivity by executing the network check script

- **Priority scheduling with a task queue**
  - Client requests include a service number and a priority level (High/Medium/Low)
  - Tasks are queued and ordered by priority and request timestamp

- **Safe synchronization**
  - The server ensures **only one instance of the same script runs at a time**, even under concurrency

- **Rate limiting**
  - Each client can submit at most one task per 5 minutes; violations are rejected and logged

- **Clear protocol + status reporting**
  - Request format: `REQUEST_TASK;ServiceNumber;ClientName;Priority`
  - Response format: `STATUS;TIMESTAMP;MESSAGE`
  - Supported status outcomes include queued/executing/completed/rejected

- **Queue management**
  - Clients can query pending tasks, cancel their queued tasks, and retrieve task history:
    - `QUEUE_STATUS`
    - `CANCEL_TASK;TaskID`
    - `TASK_HISTORY`

---

## Repository contents

Typical contents include:

- **Bash scripts** for Phase 1 automation (server + client-side scripts)
- **Java source files** for Phase 2 (server + clients)
- A **Word report** that documents the outputs with screenshots/log evidence:
  - See the report in the repository, which contains the captured outputs and results from running the scripts and Java system.

