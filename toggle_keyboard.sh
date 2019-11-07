#!/bin/bash
# Toggle the laptop keyboard either on or off and notify the user about it

# Device name can be found by typing this command: xinput list --name-only
DEVICE_NAME="AT Translated Set 2 keyboard"
# The display name of the device in the notify-send popup
DEVICE_DISPLAY_NAME="Laptop Keyboard"

# Set these to the icons you want to use.
# If they are not found, the notification will still work.
ICON_ENABLE="$HOME/.icons/keyboard.png"
ICON_DISABLE="$HOME/.icons/keyboard_disabled.png"

function xinput_set_prop() {
        xinput set-prop "$DEVICE_NAME" "Device Enabled" $1
}

function notify_change() {
        if [ -f "$1" ]; then
                notify-send --urgency=low --icon="$1" "$2"
        else
                notify-send --urgency=low "$2"
        fi
}

# Returns 1 if device is enabled, 0 if disabled
is_enabled=$(xinput list-props "$DEVICE_NAME" | grep "Device Enabled" | awk '{ print $4 }' | sed 's/[^0-9]*//g')

if [ $is_enabled -eq 1 ]; then
        # device is enabled, so disable it
        xinput_set_prop 0
        notify_change "$ICON_DISABLE" "$DEVICE_DISPLAY_NAME Disabled"
else
        # device is disabled, so enable it
        xinput_set_prop 1
        notify_change "$ICON_ENABLE" "$DEVICE_DISPLAY_NAME Enabled"
fi
