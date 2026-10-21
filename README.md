# icecc-scheduler-switch

Makes `iceccd` follow the laptop between the office LAN and home.

At the office the icecc scheduler (`csaavedra-gtk-ews`) is found by broadcast.
From home it is only reachable through its home-VPN address (`172.16.42.4`),
where broadcast does not work. These files pick the right mode automatically
and restart `iceccd` when the network changes.

## How it works

- `icecc-pick-scheduler` decides the scheduler host:
  on the office subnet (`192.168.9.0/24`) it leaves it empty (broadcast);
  elsewhere it uses `172.16.42.4` if that host answers on port 8765;
  otherwise it leaves it empty. The result goes to `/run/iceccd-scheduler.env`.
- `iceccd-scheduler.conf` is a systemd drop-in that runs the picker before
  `iceccd` starts and feeds it the env file.
- `90-iceccd` is a NetworkManager dispatcher hook that re-runs the picker on
  network changes and restarts `iceccd` only if the answer changed.

## Install

Debian/Ubuntu `icecc` package with NetworkManager:

```
sudo ./install.sh
```

The script also comments out any `ICECC_SCHEDULER_HOST=` line in
`/etc/icecc/icecc.conf`, since that would override the picker.

## Check

```
cat /run/iceccd-scheduler.env
ps -o args= -p "$(systemctl show -p MainPID --value iceccd.service)"
sudo journalctl -t icecc-pick-scheduler
```
