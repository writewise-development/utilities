SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
USERNAME=$(/mnt/c/Windows/System32/cmd.exe /c 'echo %USERNAME%' 2>/dev/null | tr -d '\r')
export USERNAME
environmentFile=$SCRIPT_DIR/../.env
if [ -f "$environmentFile" ]; then
    envVariables=$(grep -E '^[[:alnum:]_]+=' "$environmentFile")
    set -o allexport
    eval "$envVariables"
    set +o allexport
else
    echo -e "The .env file does not exist (${environmentFile}).${RESET}"
    exit 1
fi
override=$SCRIPT_DIR/../.env.local
if [ -f "$override" ]; then
    envLocalVariables=$(grep -E '^[[:alnum:]_]+=' "$override")
    set -o allexport
    eval "$envLocalVariables"
    set +o allexport
else
    default="# .env override file \n\
    echo -e "$default" > "$override"
    echo ".env.local created."
fi
