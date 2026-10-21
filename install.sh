#!/bin/sh
# Run with sudo from this directory.
set -e
# The picker only wins if icecc.conf does not set the host itself,
# so comment out any active ICECC_SCHEDULER_HOST line (no-op if none).
sed -i 's/^\(ICECC_SCHEDULER_HOST=.*\)/# \1/' /etc/icecc/icecc.conf
install -m 755 icecc-pick-scheduler /usr/local/sbin/icecc-pick-scheduler
# Never overwrite an existing rules file; seed it from the example otherwise.
if [ ! -e /etc/icecc/scheduler-switch.conf ]; then
    install -m 644 scheduler-switch.conf.example /etc/icecc/scheduler-switch.conf
    echo "NOTE: installed the example /etc/icecc/scheduler-switch.conf; edit it for your network."
fi
install -d /etc/systemd/system/iceccd.service.d
install -m 644 iceccd-scheduler.conf /etc/systemd/system/iceccd.service.d/scheduler.conf
install -m 755 90-iceccd /etc/NetworkManager/dispatcher.d/90-iceccd
systemctl daemon-reload
systemctl restart iceccd.service
echo "--- icecc.conf scheduler lines:"; grep -n 'ICECC_SCHEDULER_HOST=' /etc/icecc/icecc.conf || echo "(none)"
echo "--- env file:"; cat /run/iceccd-scheduler.env
echo "--- daemon cmdline:"; ps -o args= -p "$(systemctl show -p MainPID --value iceccd.service)" | grep -o -- "--scheduler-host [^ ]*" || echo "(no --scheduler-host: broadcast mode)"
