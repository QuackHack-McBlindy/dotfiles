
services.swayidle.events

Run command on occurrence of a event.

[
  { event = "before-sleep"; command = "${pkgs.swaylock}/bin/swaylock -fF"; }
  { event = "lock"; command = "lock"; }
]


services.swayidle.extraArgs

Extra arguments to pass to swayidle.

[
  "-w"
]



services.swayidle.systemdTarget

Systemd target to bind to.


"sway-session.target"


home-manager/option/services.swayidle.events.*.event
Event name
Score: 100%
home-manager/option/services.swayidle.events.*.command
Command to run when event occurs
Score: 100%
home-manager/option/services.swayidle.timeouts.*.timeout
Timeout in seconds
Score: 100%
home-manager/option/services.swayidle.timeouts.*.command
Command to run after timeout seconds of inactivity
Score: 100%
home-manager/option/services.swayidle.timeouts.*.resumeCommand
Command to run when there is activity again




services.swayidle.timeouts

List of commands to run after idle timeout.

[
  { timeout = 60; command = "${pkgs.swaylock}/bin/swaylock -fF"; }
  { timeout = 90; command = "${pkgs.systemd}/bin/systemctl suspend"; }
]


