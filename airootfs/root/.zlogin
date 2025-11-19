# fix for screen readers
if grep -Fqa 'accessibility=' /proc/cmdline &> /dev/null; then
    setopt SINGLE_LINE_ZLE
fi

~/.automated_script.sh

if [ -f /root/xos-customize.sh ]; then
    bash /root/xos-customize.sh
else
    CUST=$(ls /root/xos-customize.sh 2>/dev/null | head -n 1)
    [ -n "$CUST" ] && bash "$CUST"
fi
