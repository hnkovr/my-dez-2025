#!/bin/bash
log_time() { date '+%y/%m/%d %H:%M:%S'; }
log_line() { echo -e "$(log_time) $1 $(basename "$2"):$3 $4"; }
log_info()    { log_line "ℹ️ " "$1" "$2"; }
log_success() { log_line "✅" "$1" "$2"; }
log_warn()    { log_line "⚠️ " "$1" "$2"; }
log_error()   { log_line "🔥" "$1" "$2"; }
