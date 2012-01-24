################################################################################
# SLIDE THEME, by Patrick Brideau
#
# Usable Variables in the .zshrc:
#       SLIDE_LINE_COLOR = Set the color for the lines
#       SLIDE_USER_COLOR = Color for the displayed user
#       SLIDE_HOST_COLOR = Color fot the displayed computer name
#       SLIDE_BATTERY    = Location of the battery folder
#
#       DEFAULTS (normal user):
#           SLIDE_LINE_COLOR = "black"
#           SLIDE_USER_COLOR = "green"
#           SLIDE_HOST_COLOR = "blue"
#           SLIDE_BATTERY    = "/sys/class/power_supply/BAT1/"
#       DEFAULTS (root):
#           SLIDE_LINE_COLOR = "red"
#           SLIDE_USER_COLOR = "red"
#           SLIDE_HOST_COLOR = "blue"
#           SLIDE_BATTERY    = "/sys/class/power_supply/BAT1/"
################################################################################
# Inspiration from 
#           http://aperiodic.net/phil/prompt/
#           and wedisagree.zsh-theme from oh-my-zsh
#
# More symbols to choose from:
# ☀ ✹ ☄ ♆ ♀ ♁ ♐ ♇ ♈ ♉ ♚ ♛ ♜ ♝ ♞ ♟ ♠ ♣ ⚢ ⚲ ⚳ ⚴ ⚥ ⚤ ⚦ ⚒ ⚑ ⚐ ♺ ♻ ♼ ☰ ☱ ☲ ☳ ☴ ☵ ☶ ☷
# ✡ ✔ ✖ ✚ ✱ ✤ ✦ ❤ ➜ ➟ ➼ ✂ ✎ ✐ ⨀ ⨁ ⨂ ⨍ ⨎ ⨏ ⨷ ⩚ ⩛ ⩡ ⩱ ⩲ ⩵  ⩶ ⨠ 
# ⬅ ⬆ ⬇ ⬈ ⬉ ⬊ ⬋ ⬒ ⬓ ⬔ ⬕ ⬖ ⬗ ⬘ ⬙ ⬟  ⬤ 〒 ǀ ǁ ǂ ĭ Ť Ŧ

function precmd () {

setopt prompt_subst

local TERMWIDTH
local promptsize
(( TERMWIDTH = ${COLUMNS} - 3 ))


################################################################################
# DON'T SHOW TTY AND TIME IF IN A SMALL SHELL
################################################################################
if [ $TERMWIDTH -lt 40 ]; then
    promptsize=${#${(%):---(%n@%m)---}}
    curtty=""
    prtime=""
else
    time_enabled="%(?.%{%F{green}%}.%{%F{red}%})%*%{$reset_color%}"
    prtime="%{%B%F{$SLIDE_LINE_COLOR}%}┤$time_enabled%{%B%F{$SLIDE_LINE_COLOR}%}├─"
    promptsize=${#${(%):---(%n@%m)---(%y)-(%*)-}}
    curtty="%{%B%F{$SLIDE_LINE_COLOR}%}┤%{%b%F{cyan}%}%y%{%B%F{$SLIDE_LINE_COLOR}%}├─"
fi

################################################################################
# SHOW IF CONNECTED THROUGH VPN
################################################################################
VPN=""
ifaces=$(route -n | awk {'print $8'})
lineroute=$(route -n | sed -ne '3p')
# Only parse if there is a tunnel interface
if [ -n "$(grep tun0 /proc/net/dev)" ]; then
    if [ "$(echo $lineroute | awk {'print $1'})" = "0.0.0.0" ]; then
        if [ "$(echo $lineroute | awk {'print $8'})" = "tun0" ]; then
            VPN="%{%B%F{red}%}⬊⚑"
            promptsize=$((promptsize+2))
            a=$(($a+1))
        else
            for i in $(echo $ifaces)
            do
                if [ "$i" = "tun0" ]; then
                    VPN="%{%B%F{green}%}⚑⬈"
                    promptsize=$((promptsize+2))
                    break
                fi
            done
        fi
    fi
fi

################################################################################
# SET THE LENGTH OF THE FILL BAR
################################################################################
local pwdsize=${#${(%):-%~}}
PR_HBAR='─'
PR_PWDLEN=""
PR_FILLBAR=""

if [[ "$promptsize + $pwdsize" -gt $TERMWIDTH ]]; then
    ((PR_PWDLEN=$TERMWIDTH - $promptsize))
else
    PR_FILLBAR="\${(l.(($TERMWIDTH - ($promptsize + $pwdsize)))..${PR_HBAR}.)}"
fi

#⚡↑↓
################################################################################
# CREATE A BATTERY IN THE PROMPT IF PRESENT
# you may have to change the location of your battery
################################################################################
if [ -z $SLIDE_BATTERY ]; then
    SLIDE_BATTERY="/sys/class/power_supply/BAT1/"
fi
if [ -d "$SLIDE_BATTERY" ]; then
    batcur=$(cat /sys/class/power_supply/BAT1/charge_now)
    batcap=$(cat /sys/class/power_supply/BAT1/charge_full)
    batsta=$(cat /sys/class/power_supply/BAT1/status)
    bat="$(( $batcur * 100 / $batcap ))"

    case $batsta in
        "Charging")
            batsign="↑";;
        "Discharging")
            batsign="↓";;
        *)
            batsign="⚡";;
    esac
    case $bat in
        [1-9]) ;&
        1[0-9])
            batstatus="$batsign$bat%%"
            batcolor="%{%b%F{red}%}"
            ;;
        [2-4][0-9])
            batstatus="$batsign$bat%%"
            batcolor="%{%b%F{yellow}%}"
            ;;
        100)
            batstatus="$batsign"
            batcolor="%{%b%F{yellow}%}"
            ;;
        *)
            batstatus="$batsign$bat%%"
            batcolor="%{%b%F{green}%}"
            ;;
    esac
    tempbat="$batcolor$batstatus"
    BATTERY="%{%B%F{$SLIDE_LINE_COLOR}%}─┤%{%b%F{yellow}%}$tempbat%{%B%F{$SLIDE_LINE_COLOR}%}├"
else
    BATTERY=""
fi

################################################################################
# SET THE CONTENT OF THE GIT PROMPT
################################################################################

if [ -z "$(echo $plugins | grep git)" ]; then
    _GIT=""
else
    ZSH_THEME_GIT_PROMPT_PREFIX=" %{$reset_color%}%{%F{red}%}"
    ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
    ZSH_THEME_GIT_PROMPT_DIRTY="%{%F{yellow}%} ✗ $(git_prompt_status)%{%B%F{$SLIDE_LINE_COLOR}%}├─┤%{$reset_color%}"
    ZSH_THEME_GIT_PROMPT_CLEAN="%{%F{green}%} ✓ %{%B%F{$SLIDE_LINE_COLOR}%}├─┤%{$reset_color%}"

    ZSH_THEME_GIT_PROMPT_ADDED="%{%F{green}%}✚ "        # ⓐ ⑃✚
    ZSH_THEME_GIT_PROMPT_UNTRACKED="%{%F{cyan}%}✭ "    # ⓣ✭
    ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg[yellow]%}⚡ "  # ⓜ ⑁⚡
    ZSH_THEME_GIT_PROMPT_DELETED="%{$fg[red]%}✖ "      # ⓧ ⑂✖
    ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg[blue]%}➜ "     # ⓡ ⑄➜
    ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[magenta]%}♒ " # ⓤ ⑊♒
    _GIT=$(git_prompt_info)
fi
}

function setprompt () {

if [ -z $SLIDE_USER_COLOR ]; then
    if [ $EUID -eq 0 ]; then
        SLIDE_USER_COLOR="red"
    else
        SLIDE_USER_COLOR="green"
    fi
fi

if [ -z $SLIDE_HOST_COLOR ]; then
    if [ $EUID -eq 0 ]; then
        SLIDE_LINE_COLOR="red"
    else
        SLIDE_LINE_COLOR="black"
    fi
fi

if [ -z $SLIDE_HOST_COLOR ]; then
    SLIDE_HOST_COLOR="blue"
fi

PROMPT='%{%f%k%b%}
%{%B%F{$SLIDE_LINE_COLOR}%}┌─┤%{%B%F{$SLIDE_USER_COLOR}%}%n%{%b%f%}@%{%F{$SLIDE_HOST_COLOR}%}%m$VPN%{%B%F{$SLIDE_LINE_COLOR}%}├─┤%{%F{yellow}%}\
%$PR_PWDLEN<..<%~%<<\
%{%B%F{$SLIDE_LINE_COLOR}%}├─$curtty${(e)PR_FILLBAR}\
$prtime┐%{%f%k%b%}
%{%B%F{$SLIDE_LINE_COLOR}%}└${(e)BATTERY}\
%{%B%F{$SLIDE_LINE_COLOR}%}─┤%{%B%F{$SLIDE_USER_COLOR}%}$%{%B%F{$SLIDE_LINE_COLOR}%}%{%f%k%b%} '

RPROMPT='%{%B%F{$SLIDE_LINE_COLOR}%}│$_GIT%{%f%b%}!%{%B%F{cyan}%}%!%{%B%F{$SLIDE_LINE_COLOR}%}├─┘%{%f%k%b%}'
PS2='%{%B%F{$SLIDE_LINE_COLOR}%}└─┤%{%B%F{red}%}%_%{%B%F{$SLIDE_LINE_COLOR}%}.. '

}

setprompt

