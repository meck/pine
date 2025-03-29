{
  writeShellApplication,
  libgpiod,
  coreutils,
  gawk,
}:
writeShellApplication {
  name = "tatectl";

  runtimeInputs = [
    coreutils
    libgpiod
    gawk
  ];

  text = ''
    INIT_FILE="/tmp/tatectl_init"

    declare -A cape_pins=(
        [1]="P9_41A"
        [2]="P9_42A [ecappwm0]"
        [3]="P9_30 [spi1_d1]"
        [4]="P9_27"
    )

    init() {
        [ -f "$INIT_FILE" ] && return

        local pin_info
        pin_info=$(gpiocli info "''${cape_pins[@]}")
        while IFS= read -r line; do
            if ! [[ $line =~ consumer=\"gpio-manager\" ]]; then
                pin_name=$(echo "$line" | cut -d'"' -f2)
                echo "Requesting GPIO: $pin_name"
                gpiocli request --output "$pin_name" > /dev/null
            fi
        done < <(echo "$pin_info")
        touch "$INIT_FILE"
    }

    deinit() {
        local output
        output=$(gpiocli requests)
        if [[ -z "$output" ]]; then
            return 1
        fi

        mapfile -t requests < <(echo "$output" | awk '/^request[0-9]+/ {print $1}')

        for request in "''${requests[@]}"; do
            echo "Releasing: $request"
            gpiocli release "$request"
        done

        rm -f "$INIT_FILE"
    }

    cmd=""
    pin_num=""
    reinit=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            on | off | status | reset)
                cmd="$1"
                ;;
            --reinit)
                reinit=true
                ;;
            [0-9]*)
                pin_num="$1"
                ;;
            *)
                echo "Error: Invalid argument $1" >&2
                echo "Usage: $0 [--reinit] <on|off|status|reset> <pin_number>" >&2
                exit 1
                ;;
        esac
        shift
    done

    # Validate input
    if [[ -z "$cmd" ]]; then
        echo "Error: Command (on|off|status|reset) is required" >&2
        exit 1
    fi

    if [[ -z "$pin_num" ]]; then
        echo "Error: Pin number is required" >&2
        exit 1
    fi

    pin_name="''${cape_pins[$pin_num]:-}"
    if [[ -z "$pin_name" ]]; then
        echo "Error: Invalid pin number: $pin_num" >&2
        exit 1
    fi

    [[ "$reinit" == true ]] && deinit
    init

    case "$cmd" in
        on)
            gpiocli set "$pin_name"=active
            ;;
        off)
            gpiocli set "$pin_name"=inactive
            ;;
        status)
            gpiocli get "$pin_name"
            ;;
        reset)
            gpiocli set "$pin_name"=inactive
            sleep 1
            gpiocli set "$pin_name"=active
            ;;
    esac
  '';
}
