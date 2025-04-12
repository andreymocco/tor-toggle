#!/bin/bash
# <xbar.title>Tor Toggle</xbar.title>
# <xbar.version>v1.0.000</xbar.version>
# <xbar.author>Andrey Mo</xbar.author>
# <xbar.author.github>andreymocco</xbar.author.github>
# <xbar.desc>Toggle Tor, change identity, check IP, and manage bridges. Requires Tor and curl.</xbar.desc>
# <xbar.dependencies>tor,curl</xbar.dependencies>
# <xbar.abouturl>https://github.com/andreymocco/tor-toggle</xbar.abouturl>
# <swiftbar.hideAbout>true</swiftbar.hideAbout>
# <swiftbar.hideRunInTerminal>true</swiftbar.hideRunInTerminal>
# <swiftbar.hideLastUpdated>true</swiftbar.hideLastUpdated>
# <swiftbar.hideDisablePlugin>true</swiftbar.hideDisablePlugin>
# <swiftbar.hideSwiftBar>true</swiftbar.hideSwiftBar>

# CONFIG
TOR_PATH="/opt/homebrew/bin/tor"
TORRC_PATH="/opt/homebrew/etc/tor/torrc"
SOCKS_PROXY="socks5h://127.0.0.1:9050"
CONTROL_PORT="9051"
CONTROL_COOKIE="/opt/homebrew/var/lib/tor/control_auth_cookie"

# Determine system language
SYSTEM_LANG=$(defaults read -g AppleLocale)

# Set language-dependent messages
if [[ "$SYSTEM_LANG" == "ru_RU" ]]; then
    TOR_STARTED="Tor запущен успешно"
    TOR_STOPPED="Tor выключен"
    TOR_FAILED_START="Не удалось запустить Tor"
    TOR_FAILED_STOP="Не удалось завершить Tor"
    NEW_BRIDGE="Новый мост:"
    REPLACE_BRIDGE="Заменить мост"
    CONFIG_UPDATED="Мост успешно обновлён"
    NEW_CHAIN="Запрошена новая цепочка Tor"
    TOR_IP="Запросить Tor IP"
    TOR_IP_NOTIFY="Tor IP"
    OPEN_CONFIG="Открыть конфигуратор"
    OPEN_SCRIPT="Открыть скрипт"
    UPDATE_MENU="Обновить меню"
    REPLACE_BUTTON_OK="Заменить"
    REPLACE_BUTTON_CANCEL="Отмена"
    START_SESSION="Начать сеанс"
    STOP_SESSION="Завершить сеанс"
    MANAGEMENT="Управление"
    CONFIGURATION="Конфигурация"
    CHANGE_CHAIN="Сменить цепочку Tor"
    GET_IP_COUNTRY="Проверить IP и страну"
    GET_IP_COUNTRY_FAILED="Не удалось получить ответ"
else
    TOR_STARTED="Tor started successfully"
    TOR_STOPPED="Tor stopped"
    TOR_FAILED_START="Failed to start Tor"
    TOR_FAILED_STOP="Failed to stop Tor"
    NEW_BRIDGE="New bridge:"
    REPLACE_BRIDGE="Replace bridge"
    CONFIG_UPDATED="Bridge updated successfully"
    NEW_CHAIN="New Tor chain requested"
    TOR_IP="Request Tor IP"
    TOR_IP_NOTIFY="Tor IP"
    OPEN_CONFIG="Open configurator"
    OPEN_SCRIPT="Open script"
    UPDATE_MENU="Update menu"
    REPLACE_BUTTON_OK="Replace"
    REPLACE_BUTTON_CANCEL="Cancel"
    START_SESSION="Start session"
    STOP_SESSION="Stop session"
    MANAGEMENT="Management"
    CONFIGURATION="Configuration"
    CHANGE_CHAIN="Change Tor identity"
    GET_IP_COUNTRY="Check IP & Country"
    GET_IP_COUNTRY_FAILED="Couldn't get a response"
fi

# Base64-encoded SVG icons
ICON_ON="PHN2ZyB3aWR0aD0iMjAiIGhlaWdodD0iMjAiIHZpZXdCb3g9IjAgMCAyMCAyMCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZD0iTTguNSAxNEM4LjUgMTUuMzgwNyA3LjM4MDcxIDE2LjUgNiAxNi41QzQuNjE5MjkgMTYuNSAzLjUgMTUuMzgwNyAzLjUgMTRDMy41IDEyLjYxOTMgNC42MTkyOSAxMS41IDYgMTEuNUM3LjM4MDcxIDExLjUgOC41IDEyLjYxOTMgOC41IDE0Wk04LjUgMTRDOC41IDE0IDkgMTMuNSAxMCAxMy41QzExIDEzLjUgMTEuNSAxNCAxMS41IDE0TTExLjUgMTRDMTEuNSAxNS4zODA3IDEyLjYxOTMgMTYuNSAxNCAxNi41QzE1LjM4MDcgMTYuNSAxNi41IDE1LjM4MDcgMTYuNSAxNEMxNi41IDEyLjYxOTMgMTUuMzgwNyAxMS41IDE0IDExLjVDMTIuNjE5MyAxMS41IDExLjUgMTIuNjE5MyAxMS41IDE0Wk0yIDguNUg0TTQgOC41TDcuNSAzLjVIMTIuNUwxNiA4LjVNNCA4LjVIMTZNMTggOC41SDE2IiBzdHJva2U9ImJsYWNrIiBzdHJva2Utd2lkdGg9IjEuMjUiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIvPgo8L3N2Zz4K"
ICON_OFF="PHN2ZyB3aWR0aD0iMjAiIGhlaWdodD0iMjAiIHZpZXdCb3g9IjAgMCAyMCAyMCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPGcgb3BhY2l0eT0iMC4zIj4KPHBhdGggZD0iTTguNSAxNEM4LjUgMTUuMzgwNyA3LjM4MDcxIDE2LjUgNiAxNi41QzQuNjE5MjkgMTYuNSAzLjUgMTUuMzgwNyAzLjUgMTRDMy41IDEyLjYxOTMgNC42MTkyOSAxMS41IDYgMTEuNUM3LjM4MDcxIDExLjUgOC41IDEyLjYxOTMgOC41IDE0Wk04LjUgMTRDOC41IDE0IDkgMTMuNSAxMCAxMy41QzExIDEzLjUgMTEuNSAxNCAxMS41IDE0TTExLjUgMTRDMTEuNSAxNS4zODA3IDEyLjYxOTMgMTYuNSAxNCAxNi41QzE1LjM4MDcgMTYuNSAxNi41IDE1LjM4MDcgMTYuNSAxNEMxNi41IDEyLjYxOTMgMTUuMzgwNyAxMS41IDE0IDExLjVDMTIuNjE5MyAxMS41IDExLjUgMTIuNjE5MyAxMS41IDE0Wk0yIDguNUg0TTQgOC41TDcuNSAzLjVIMTIuNUwxNiA4LjVNNCA4LjVIMTZNMTggOC41SDE2IiBzdHJva2U9ImJsYWNrIiBzdHJva2Utd2lkdGg9IjEuMjUiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIvPgo8L2c+Cjwvc3ZnPgo="
ICON_STOP="PHN2ZyB3aWR0aD0iMjAiIGhlaWdodD0iMjAiIHZpZXdCb3g9IjAgMCAyMCAyMCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZD0iTTguNSA4VjEyTTEyLjUgMTJWOE0xNy41IDEwQzE3LjUgMTMuODY2IDE0LjM2NiAxNyAxMC41IDE3QzYuNjM0MDEgMTcgMy41IDEzLjg2NiAzLjUgMTBDMy41IDYuMTM0MDEgNi42MzQwMSAzIDEwLjUgM0MxNC4zNjYgMyAxNy41IDYuMTM0MDEgMTcuNSAxMFoiIHN0cm9rZT0iYmxhY2siIHN0cm9rZS13aWR0aD0iMS4yNSIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIi8+Cjwvc3ZnPgo="
ICON_START="PHN2ZyB3aWR0aD0iMjAiIGhlaWdodD0iMjAiIHZpZXdCb3g9IjAgMCAyMCAyMCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZD0iTTEzLjgxMjUgMTBMOC44MTI1IDdWMTNMMTMuODEyNSAxME0xNy41IDEwQzE3LjUgMTMuODY2IDE0LjM2NiAxNyAxMC41IDE3QzYuNjM0MDEgMTcgMy41IDEzLjg2NiAzLjUgMTBDMy41IDYuMTM0MDEgNi42MzQwMSAzIDEwLjUgM0MxNC4zNjYgMyAxNy41IDYuMTM0MDEgMTcuNSAxMFoiIHN0cm9rZT0iYmxhY2siIHN0cm9rZS13aWR0aD0iMS4yNSIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIi8+Cjwvc3ZnPgo="
ICON_GET_IP="PHN2ZyB3aWR0aD0iMjAiIGhlaWdodD0iMjAiIHZpZXdCb3g9IjAgMCAyMCAyMCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZD0iTTExLjU4NyAzLjA4Mzg5QzExLjIzMjcgMy4wMjg2NiAxMC44Njk3IDMgMTAuNSAzQzYuNjM0MDEgMyAzLjUgNi4xMzQwMSAzLjUgMTBDMy41IDEwLjg5MTEgMy42NjY1IDExLjc0MzMgMy45NzAxIDEyLjUyNzJNMTEuNTg3IDMuMDgzODlDMTEuNTczNiA0LjAyOTg4IDExIDYuMDI4MTIgOC44MTI1IDYuNDUzMTJDOS44NDM3NSA2Ljg2NDU4IDExLjU3NSA4LjIzNDM4IDEwLjI1IDEwLjQyMTlDOC45MjUgMTIuNjA5NCA3LjM0Mzc1IDExLjY0NTggNi43MTg3NSAxMC44OTA2QzYuMDYzNCAxMS40NDUyIDQuNTk2MTggMTIuNTQ5IDMuOTcwMSAxMi41MjcyTTExLjU4NyAzLjA4Mzg5QzEzLjUyMjkgMy4zODU3MSAxNS4xOTYyIDQuNDgwOTMgMTYuMjYzOCA2LjAyNjU4TTMuOTcwMSAxMi41MjcyQzQuNzE0NjYgMTQuNDQ5NyA2LjI4Mzc3IDE1Ljk2MTQgOC4yNDM1NCAxNi42Mjg0TTguMjQzNTQgMTYuNjI4NEM4Ljk1MTUzIDE2Ljg2OTMgOS43MTA1IDE3IDEwLjUgMTdDMTIuMDg1IDE3IDEzLjU0NjkgMTYuNDczMiAxNC43MjAzIDE1LjU4NTJNOC4yNDM1NCAxNi42Mjg0QzguNDIyNzggMTUuNzczMSA5LjIyNSAxMy45OTA2IDExIDEzLjcwMzFDMTIuNzc1IDEzLjQxNTYgMTQuMjE5OCAxNC44MzgxIDE0LjcyMDMgMTUuNTg1Mk0xNC43MjAzIDE1LjU4NTJDMTYuMDgyMiAxNC41NTQ1IDE3LjA1NTMgMTMuMDM3MyAxNy4zODEgMTEuMjkyMk0xNy4zODEgMTEuMjkyMkMxNy40NTkxIDEwLjg3MzQgMTcuNSAxMC40NDE1IDE3LjUgMTBDMTcuNSA4LjUyNDM1IDE3LjA0MzQgNy4xNTUzNSAxNi4yNjM4IDYuMDI2NThNMTcuMzgxIDExLjI5MjJDMTYuMzk5OCAxMS4yOTM3IDE0LjQwMzEgMTAuODEyNSAxNC4yNjU2IDguODc1QzE0LjEyODEgNi45Mzc1IDE1LjU0MDQgNi4xNjg3NiAxNi4yNjM4IDYuMDI2NTgiIHN0cm9rZT0iYmxhY2siIHN0cm9rZS13aWR0aD0iMS4yNSIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIi8+Cjwvc3ZnPgo="
ICON_CHANGE_IDENTITY="PHN2ZyB3aWR0aD0iMjAiIGhlaWdodD0iMjAiIHZpZXdCb3g9IjAgMCAyMCAyMCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZD0iTTUuODU0NCA2LjYwNTg2VjYuOTQzMjZNNi4zMTA2MSAxMC4yMzQ0QzYuMzEwNjEgMTAuMjM0NCA2LjY4NzUgMTAuNTkzOCA3LjM4OTQgMTAuNTkzOEM4LjA5MTMxIDEwLjU5MzggOC40NjgyIDEwLjIzNDQgOC40NjgyIDEwLjIzNDRNMTQuNzA2OSAxMC4xMzg2VjEwLjQ3Nk0xNC4yNTA3IDE0LjEyNjVDMTQuMjUwNyAxNC4xMjY1IDEzLjg3MzggMTMuNzY3MSAxMy4xNzE5IDEzLjc2NzFDMTIuNDcgMTMuNzY3MSAxMi4wOTMxIDE0LjEyNjUgMTIuMDkzMSAxNC4xMjY1TTguOTI0NCA2LjYwNTg2VjYuOTQzMjZNMTAuNDg0NCAxNi40Njg4QzExLjM1OTQgMTcuMzU5NCAxMi41OTM4IDE3LjU1MTkgMTMuMTcxOSAxNy41NTE5QzEzLjc1IDE3LjU1MTkgMTguMDE5MiAxNi40Njg0IDE4LjAxOTIgMTAuOTkzOUMxOC4wMTkyIDcuNzc1MDcgMTYuMjczNiA2LjQ4MTA4IDE0LjcwNjkgNi4wNzY2MU03LjM4OTQgMi40MDQ3OUM1LjU3NTY4IDIuNDA0NzkgMi41NDIxMSAzLjA4MTU3IDIuNTQyMTEgNy40NjExOEMyLjU0MjExIDEyLjkzNTcgNi40NTA2OCAxMy45Mzc1IDcuMzg5NCAxMy45Mzc1QzguMzI4MTIgMTMuOTM3NSAxMi4yMzY3IDEyLjkzNTcgMTIuMjM2NyA3LjQ2MTE4QzEyLjIzNjcgMy4wODE1NyA5LjIwMzEyIDIuNDA0NzkgNy4zODk0IDIuNDA0NzlaIiBzdHJva2U9ImJsYWNrIiBzdHJva2Utd2lkdGg9IjEuMjUiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIvPgo8L3N2Zz4K"
ICON_REPLACE_BRIDGE="PHN2ZyB3aWR0aD0iMjAiIGhlaWdodD0iMjAiIHZpZXdCb3g9IjAgMCAyMCAyMCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZD0iTTMuNDY4NzUgNi45MTMwNEMzLjkzNzUgNi45MTMwNCA1LjA2MjUgNi41MzA0MyA1LjgxMjUgNU01LjgxMjUgNUM2LjEyNSA2LjI3NTM2IDcuNSA4LjgyNjA5IDEwLjUgOC44MjYwOU01LjgxMjUgNVYxMi42NTIyTTUuODEyNSAxNlYxMi42NTIyTTMgMTIuNjUyMkg1LjgxMjVNMTAuNSAxMi42NTIyVjguODI2MDlNMTAuNSAxMi42NTIySDUuODEyNU0xMC41IDEyLjY1MjJIMTUuMTg3NU0xMC41IDguODI2MDlDMTMuNSA4LjgyNjA5IDE0Ljg3NSA2LjI3NTM2IDE1LjE4NzUgNU0xNy41MzEyIDYuOTEzMDRDMTcuMDYyNSA2LjkxMzA0IDE1LjkzNzUgNi41MzA0MyAxNS4xODc1IDVNMTUuMTg3NSA1VjEyLjY1MjJNMTUuMTg3NSAxNlYxMi42NTIyTTE4IDEyLjY1MjJIMTUuMTg3NU01LjgxMjUgMTIuNjUyMkgxNS4xODc1IiBzdHJva2U9ImJsYWNrIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiLz4KPC9zdmc+Cg=="
# ICON_OPEN_SCRIPT="PHN2ZyB3aWR0aD0iMjAiIGhlaWdodD0iMjAiIHZpZXdCb3g9IjAgMCAyMCAyMCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZD0iTTUuODc0MTUgNC4zODY0N0M1Ljg3NDE1IDQuMzg2NDcgNC40ODU2MiA0LjM4NjQ3IDQuNDg1NjIgNS45MzM3NVY4LjYxMTYyQzQuNDg1NjIgMTAuMDAwMSAyLjk1ODI1IDEwLjAwMDEgMi45NTgyNSAxMC4wMDAxQzIuOTU4MjUgMTAuMDAwMSA0LjQ4NTYyIDEwLjAwMDEgNC40ODU2MiAxMS4zODg2VjE0LjA2NjRDNC40ODU2MiAxNS42MTM3IDUuODc0MTUgMTUuNjEzNyA1Ljg3NDE1IDE1LjYxMzdNMTQuMTI1OSA0LjM4NjQ3QzE0LjEyNTkgNC4zODY0NyAxNS41MTQ0IDQuMzg2NDcgMTUuNTE0NCA1LjkzMzc1VjguNjExNjJDMTUuNTE0NCAxMC4wMDAxIDE3LjA0MTggMTAuMDAwMSAxNy4wNDE4IDEwLjAwMDFDMTcuMDQxOCAxMC4wMDAxIDE1LjUxNDQgMTAuMDAwMSAxNS41MTQ0IDExLjM4ODZWMTQuMDY2NEMxNS41MTQ0IDE1LjYxMzcgMTQuMTI1OSAxNS42MTM3IDE0LjEyNTkgMTUuNjEzN003LjY5Nzc2IDEwLjAwMDFIMTIuMzAyMyIgc3Ryb2tlPSJibGFjayIgc3Ryb2tlLXdpZHRoPSIxLjI1IiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiLz4KPC9zdmc+Cg=="

# FUNCTIONS
is_tor_running() {
    pgrep -x tor > /dev/null
}


get_icon_symbol() {
    if is_tor_running; then
        echo "| templateImage=$ICON_ON tooltip=test"
    else
        echo "| templateImage=$ICON_OFF tooltip=test"
    fi
}

# Function to wait until Tor starts or stops
wait_for_tor() {
    local max_attempts=5
    local i=0

    while [ $i -lt $max_attempts ]; do
        sleep 1
        if is_tor_running; then
            return 0  # Tor is running
        elif ! is_tor_running; then
            return 1  # Tor is stopped
        fi
        ((i++))
    done

    return 2  # Exceeded max attempts
}

toggle_tor() {
    if is_tor_running; then
        pkill -x tor

        # Wait until Tor actually stops
        if ! wait_for_tor; then
            osascript -e "display notification \"$TOR_STOPPED\" with title \"Tor Control\""
        else
            osascript -e "display notification \"$TOR_FAILED_STOP\" with title \"Tor Control\""
        fi
    else
        "$TOR_PATH" -f "$TORRC_PATH" &

        # Wait until Tor actually starts
        if wait_for_tor; then
            osascript -e "display notification \"$TOR_STARTED\" with title \"Tor Control\""
        else
            osascript -e "display notification \"$TOR_FAILED_START\" with title \"Tor Control\""
        fi
    fi

    # After confirming the state change — update the menu
    open -g "swiftbar://refreshplugin?name=$(basename "$0")"
}

change_identity() {
    printf 'AUTHENTICATE ""\nSIGNAL NEWNYM\nQUIT\n' | nc 127.0.0.1 "$CONTROL_PORT"
    osascript -e "display notification \"$NEW_CHAIN\" with title \"Tor Control\""
}

# Function to update the bridge (replace old bridge with a new one)
replace_bridge() {
    NEW_BRIDGE=$(osascript <<EOF
    tell application "System Events"
        set result to display dialog "$NEW_BRIDGE" default answer "" with title "Tor Bridge" buttons {"$REPLACE_BUTTON_CANCEL", "$REPLACE_BUTTON_OK"} default button 2
        if button returned of result is "$REPLACE_BUTTON_CANCEL" then
            return ""
        else
            return text returned of result
        end if
    end tell
EOF
    )

    if [[ -n "$NEW_BRIDGE" ]]; then
        # Backup torrc
        cp "$TORRC_PATH" "$TORRC_PATH.bak"

        # Replace Bridge obfs4 line
        sed -i '' "s|^Bridge .*|Bridge $NEW_BRIDGE|" "$TORRC_PATH"

        osascript -e "display notification \"$CONFIG_UPDATED\" with title \"Tor Control\""

        # Restart Tor (optional)
        if is_tor_running; then
            pkill -x tor
            sleep 1
            "$TOR_PATH" -f "$TORRC_PATH" &

            # Wait until Tor starts after replacing the bridge
            if wait_for_tor; then
                osascript -e "display notification \"$TOR_STARTED\" with title \"Tor Control\""
            else
                osascript -e "display notification \"$TOR_FAILED_START\" with title \"Tor Control\""
            fi

            # After confirming the state change — update the menu
            open -g "swiftbar://refreshplugin?name=$(basename "$0")"
        fi
    fi
}

get_ip_country() {
    # Extract the address and port from SOCKS_PROXY
    SOCKS_HOST=$(echo "$SOCKS_PROXY" | sed -E 's|^[^:]+://([^:]+):.*|\1|')
    SOCKS_PORT=$(echo "$SOCKS_PROXY" | sed -E 's|.*:([0-9]+)$|\1|')

    RESPONSE=$(curl --socks5-hostname "$SOCKS_HOST:$SOCKS_PORT" -s http://ip-api.com/json)

    IP=$(echo "$RESPONSE" | grep -oE '"query":"[^"]+"' | cut -d':' -f2 | tr -d '"')
    COUNTRY=$(echo "$RESPONSE" | grep -oE '"country":"[^"]+"' | cut -d':' -f2 | tr -d '"')
    CITY=$(echo "$RESPONSE" | grep -oE '"city":"[^"]+"' | cut -d':' -f2 | tr -d '"')

    if [[ -n "$IP" && -n "$COUNTRY" ]]; then
        osascript -e "display notification \"$IP ($CITY, $COUNTRY)\" with title \"$TOR_IP_NOTIFY\""
    else
        osascript -e "display notification \"Failed to detect country\" with title \"Tor Control\""
    fi
}

get_ip() {
    curl --socks5-hostname 127.0.0.1:9050 -s https://check.torproject.org/api/ip | grep -oE '"IP":"[^"]+"' | cut -d':' -f2 | tr -d '"'
}

# HANDLE ACTIONS
case "$1" in
    toggle)
        toggle_tor
        ;;
    ip)
        osascript -e "display notification \"$(get_ip)\" with title \"$TOR_IP_NOTIFY\""
        ;;
    newnym)
        change_identity
        ;;
    replace_bridge)
        replace_bridge
        ;;
    country)
        get_ip_country
        ;;
esac

# OUTPUT FOR SWIFTBAR
ICON=$(get_icon_symbol)
echo "$ICON"
echo "---"

if is_tor_running; then
    echo "$STOP_SESSION | templateImage=$ICON_STOP bash='$0' param1=toggle terminal=false refresh=true"
else
    echo "$START_SESSION | templateImage=$ICON_START bash='$0' param1=toggle terminal=false refresh=true"
fi

echo "---"

if is_tor_running; then
    echo "$GET_IP_COUNTRY | templateImage=$ICON_GET_IP bash='$0' param1=country terminal=false refresh=true"
    echo "$TOR_IP | templateImage=$ICON_GET_IP bash='$0' param1=ip terminal=false refresh=true alternate=True"
    echo "$CHANGE_CHAIN | templateImage=$ICON_CHANGE_IDENTITY bash='$0' param1=newnym terminal=false refresh=true"
fi
echo "$REPLACE_BRIDGE | templateImage=$ICON_REPLACE_BRIDGE bash='$0' param1=replace_bridge terminal=false refresh=true"