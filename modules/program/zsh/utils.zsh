# Path additions
export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$HOME/.npm-global/bin:$PATH"

# Proxy Management Logic
typeset -A proxy_map=(
    [qs]="9674"
    [hiddify]="7890"
    [clash]="7890"
)

proxy_on() {
    local input="${1:-hiddify}"
    local port="${proxy_map[$input]:-$input}"

    if [[ ! "$port" =~ ^[0-9]+$ ]]; then
      echo -e "\033[31mError: Unknown proxy profile or invalid port '$input'\033[0m"
      return 1
    fi

    export http_proxy="http://127.0.0.1:$port"
    export https_proxy="http://127.0.0.1:$port"
    export all_proxy="socks5://127.0.0.1:$port"
    echo -e "Proxy \033[32mON\033[0m (Port: \033[34m$port\033[0m)"
}

proxy_off() {
    unset http_proxy https_proxy all_proxy
    echo -e "Proxy \033[31mOFF\033[0m"
}