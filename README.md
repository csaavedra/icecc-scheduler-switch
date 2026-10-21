# icecc-scheduler-switch

Makes `iceccd` follow a laptop between networks.

`iceccd` finds its scheduler by broadcast unless it is given a host, and
broadcast does not cross VPNs or routed subnets. This picks the scheduler
host from a small set of rules (for example: broadcast on the office LAN,
the scheduler's VPN address elsewhere) and restarts `iceccd` when the
network changes and the answer differs.

## How it works

- `/etc/icecc/scheduler-switch.conf` lists rules, one per line, as
  `<scheduler> <condition>`. The first rule that holds wins; with no match
  `iceccd` uses broadcast. Conditions are `subnet CIDR`, `reachable`
  (the scheduler answers on port 8765), `reachable HOST[:PORT]` and
  `always`. See `scheduler-switch.conf.example`.
- `icecc-pick-scheduler` evaluates the rules and writes the result to
  `/run/iceccd-scheduler.env`.
- `iceccd-scheduler.conf` is a systemd drop-in that runs the picker before
  `iceccd` starts and feeds it the env file.
- `90-iceccd` is a NetworkManager dispatcher hook that re-runs the picker on
  network changes and restarts `iceccd` only if the answer changed.

## Install

Debian/Ubuntu `icecc` package with NetworkManager:

```
sudo ./install.sh
sudoedit /etc/icecc/scheduler-switch.conf
sudo systemctl restart iceccd
```

The script installs the example rules only if
`/etc/icecc/scheduler-switch.conf` does not exist yet. It also comments out
any `ICECC_SCHEDULER_HOST=` line in `/etc/icecc/icecc.conf`, since that
would override the picker.

## Check

```
cat /run/iceccd-scheduler.env
ps -o args= -p "$(systemctl show -p MainPID --value iceccd.service)"
sudo journalctl -t icecc-pick-scheduler
```

The journal shows each decision and the rule that made it.

## License

MIT, see `LICENSE`.
