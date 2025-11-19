if grep -Fqa 'accessibility=' /proc/cmdline &> /dev/null; then
    setopt SINGLE_LINE_ZLE
fi

[ -f /root/xos-autostart.sh ] && bash /root/xos-autostart.sh
