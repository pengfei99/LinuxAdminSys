# Systemd in Linux

In Debian (and other Linux distributions), we use **systemd** to manage services which should run as `background process`
We use a `unit file` to define how the service should be start/stop/restart, and how to monitor the service status. 
After editing and enabling the `unit` file, these services can be controlled by using the **systemctl** command.


> Systemd is developed to replace the old **SysV init**. 

## What is a service in linux 

A **service** is usually a `long running daemon (background program) process` like nginx, postgresql, or ssh.

Each service has a corresponding `unit file` that tells `systemd` how to `start, stop, restart, or monitor it`.

The Unit files live in:

- `/lib/systemd/system/`: (packaged services)
- `/etc/systemd/system/`: (local overrides/custom services)

## Useful systemd commands

```shell
# list all active services
systemctl list-units --type=service

# list all service(active and inactive)
systemctl list-units --type=service --all

# start a service immediately
systemctl start ssh

# stop immediately
systemctl stop ssh

# restart 
systemctl restart ssh

# check service status
systemctl status ssh

# Enable/disable a service at boot
systemctl enable/disable ssh

# check if a service is enabled at boot
systemctl is-enabled ssh
```

## Why we use systemd

Compared to a bash script, the systemd has the below advantages:
- **Automatic management**: Starts at boot, restarts if it fails.
- **Dependency awareness**: Can wait for network/storage service before starting.
- **Logging integration**: Logs go to journalctl -u postgresql.
- **Resource control**: Built-in cgroups support (limit memory, CPU, I/O).
- **Monitoring tools**: systemctl status postgresql shows PID, uptime, logs.
- **Unified interface**: Consistent commands across all services.

It has few disadvantages:
- Less transparent: Logic hidden inside systemd unit file, not just a simple script.
- Steeper learning curve: You need to learn how to write `unit files` and systemd internals.
- Systemd dependency: If OS does not have it, the unit file won’t work.
- Overhead for simple cases – For a single local process, systemd may feel like “overkill.”

## Systemd Unit file

There is a more detailed doc on unit file [here](https://www.digitalocean.com/community/tutorials/understanding-systemd-units-and-unit-files)

A systemd unit file is structured into `sections`. The three most common are **[Unit], [Service], and [Install]**. 
Each has a distinct purpose:
- [Unit]: metadata + dependencies. When and under what conditions should this service start?
- [Service]: execution details. How do we start, stop, restart, and monitor this process?
- [Install]: startup integration. Should this run automatically at boot, and in which boot mode?

### [Unit] section

The unit section defines `metadata and dependencies` for the service.
Below are the most common attributes of this section:
- Description: Human-readable description of the service.
- Documentation: Optional links to docs.
- After: Order dependency (start this service after something else, e.g. network.target).
- Requires: Hard dependency (if required service fails, this one stops too).
- Wants: Soft dependency (preferred, but doesn’t stop if missing).

For example, the below conf means:
- The `OpenMetadata Service` starts after the network stack is ready.
- It needs `PostgreSQL and elasticsearch`; if PostgreSQL or elasticsearch fails, OpenMetadata stops too.

```shell
[Unit]
Description=OpenMetadata Service
After=network.target
Requires=postgresql.service, elasticsearch.service
```

### [Service] section

The service section defines how the actual service runs.

- ExecStart: The actual command to start the service.
- ExecStop: Command to stop it.
- ExecReload: Command to reload config without restart.
- WorkingDirectory: Where the service runs.
- User=/Group: Run as specific user/group (not root).
- Restart: Restart policy (no, on-failure, always).
- RestartSec: Delay before restart.
- Environment: Set environment variables.
- StandardOutput=/StandardError: Where logs go (journal, file, etc.).
- Type: How the service runs:
         - simple: Default, process runs in foreground.
         - forking: For daemons that fork themselves (e.g. old scripts). 
         - oneshot: For short-lived tasks (runs once, exits).

```shell
[Service]
User=openmeta
Group=openmeta
WorkingDirectory=/opt/openmetadata
ExecStart=/opt/openmetadata/openmetadata.sh start
ExecStop=/opt/openmetadata/openmetadata.sh stop
Restart=on-failure
RestartSec=5
StandardOutput=journal
StandardError=journal
```
> The user openmeta must exist, otherwise the service will not start.
>
#### Run service with dedicated user and group

If we don't specify `User/group`, **systemd** will run the service as **root** with the user default group(e.g. root). 
This can cause serious security problems. The best practice is that we always create a dedicated system user account and group.

```shell
# create a system group
sudo groupadd --system openmeta
# create a system user with no login shell, no home dir.
sudo useradd --system --no-create-home --shell /usr/sbin/nologin --gid openmeta openmeta
```

### [Install] section

The install section defines how the service integrates into system startup.
- **WantedBy**: Which target this service should be part of when enabled.
    - multi-user.target: Typical for servers (like runlevel 3 in SysV).
    - graphical.target: For desktop services (like runlevel 5).

- **RequiredBy**: Like WantedBy, but hard dependency.

For example, the below config means: When you run systemctl enable openmetadata.service, systemd creates symlinks 
so the service starts automatically in multi-user mode (normal boot without GUI).

```shell
[Install]
WantedBy=multi-user.target
```

### Full example

The below unit file shows how to run openmetadata as systemd service
```shell
[Unit]
Description=OpenMetadata Service
After=network.target
Wants=network.target
Requires=postgresql.service elasticsearch.service

[Service]
Type=forking
# Run as non-root user
User=openmeta
Group=openmeta
WorkingDirectory=/opt/

# load env var
EnvironmentFile=-/opt/openmetadata/conf/openmetadata-env.sh

# How to start and stop
ExecStart=/opt/openmetadata/openmetadata.sh start
ExecStop=/opt/openmetadata/openmetadata.sh stop

# checking service health.
ExecReload=/opt/openmetadata/openmetadata.sh status
# Optional: status and clean hooks
ExecStartPre=/opt/openmetadata/openmetadata.sh clean

# Restart policy if the service crashes
Restart=on-failure
RestartSec=5

# Logging: send stdout/stderr to systemd journal
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

> We suppose the openmetadata app is installed under `/opt/openmetadata`