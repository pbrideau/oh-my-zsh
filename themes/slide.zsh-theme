# Inspiration from 
#           http://aperiodic.net/phil/prompt/
#           and wedisagree.zsh-theme from oh-my-zsh
# More symbols to choose from:
# ☀ ✹ ☄ ♆ ♀ ♁ ♐ ♇ ♈ ♉ ♚ ♛ ♜ ♝ ♞ ♟ ♠ ♣ ⚢ ⚲ ⚳ ⚴ ⚥ ⚤ ⚦ ⚒ ⚑ ⚐ ♺ ♻ ♼ ☰ ☱ ☲ ☳ ☴ ☵ ☶ ☷
# ✡ ✔ ✖ ✚ ✱ ✤ ✦ ❤ ➜ ➟ ➼ ✂ ✎ ✐ ⨀ ⨁ ⨂ ⨍ ⨎ ⨏ ⨷ ⩚ ⩛ ⩡ ⩱ ⩲ ⩵  ⩶ ⨠ 
# ⬅ ⬆ ⬇ ⬈ ⬉ ⬊ ⬋ ⬒ ⬓ ⬔ ⬕ ⬖ ⬗ ⬘ ⬙ ⬟  ⬤ 〒 ǀ ǁ ǂ ĭ Ť Ŧ

function precmd () {

setopt prompt_subst

local TERMWIDTH
local promptsize
(( TERMWIDTH = ${COLUMNS} - 3 ))


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
if [ -d "/sys/class/power_supply/BAT1" ]; then
    batcur=$(cat /sys/class/power_supply/BAT1/charge_now)
    batcap=$(cat /sys/class/power_supply/BAT1/charge_full)
    batsta=$(cat /sys/class/power_supply/BAT1/status)
    bat="$(( $batcur * 100 / $batcap ))"
    if [ $bat -lt 30 ]; then
        batcolor="%{%b%F{red}%}"
    else
        if [ $bat -eq 100 ]; then
            batcolor="%{%b%F{yellow}%}"
        else
            batcolor="%{%b%F{green}%}"
        fi
    fi
    if [ "$batsta" = "Charging" ]; then
        batsign="↑"
    else 
        if [ "$batsta" = "Discharging" ]; then
            batsign="↓"
        else
            batsign="⚡"
        fi
    fi
    if [ $bat -eq 100 ]; then
        batstatus="$batsign"
    else
        batstatus="$batsign$bat%%"
    fi
    tempbat="$batcolor$batstatus"
    BATTERY="%{%B%F{$linecolor}%}─┤%{%b%F{yellow}%}$tempbat%{%B%F{$linecolor}%}├"
else
    BATTERY=""
fi

ZSH_THEME_GIT_PROMPT_PREFIX=" %{$reset_color%}%{%F{red}%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{%F{yellow}%} ✗ $(git_prompt_status)%{%B%F{$linecolor}%}├─┤%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{%F{green}%} ✓ %{%B%F{$linecolor}%}├─┤%{$reset_color%}"

ZSH_THEME_GIT_PROMPT_ADDED="%{%F{green}%}ⓐ "        # ⓐ ⑃✚
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{%F{cyan}%}ⓣ "    # ⓣ✭
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg[yellow]%}ⓜ "  # ⓜ ⑁⚡
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg[red]%}ⓧ "      # ⓧ ⑂✖
ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg[blue]%}ⓡ "     # ⓡ ⑄➜
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[magenta]%}ⓤ " # ⓤ ⑊♒

if [ ! "$(echo $plugins | grep git)" ]; then
    git_prompt_info=""
    git_prompt_status=""
fi
}

function setprompt () {

usercolor=""
linecolor=""
if [ $EUID -eq 0 ]; then
    usercolor="red"
    linecolor="red"
else
    usercolor="green"
    linecolor="black"
fi

if [ -z $SLIDE_HOST_COLOR ]; then
    SLIDE_HOST_COLOR="blue"
fi

PROMPT='%{%f%k%b%}
%{%B%F{$linecolor}%}┌─┤%{%B%F{$usercolor}%}%n%{%b%f%}@%{%F{$SLIDE_HOST_COLOR}%}%m%{%B%F{$linecolor}%}├─┤%{%F{yellow}%}\
%$PR_PWDLEN<..<%~%<<\
%{%B%F{$linecolor}%}├─$curtty${(e)PR_FILLBAR}\
$prtime┐%{%f%k%b%}
%{%B%F{$linecolor}%}└${(e)BATTERY}\
%{%B%F{$linecolor}%}─┤%{%B%F{$usercolor}%}$%{%B%F{$linecolor}%}%{%f%k%b%} '

RPROMPT='%{%B%F{$linecolor}%}│$(git_prompt_info)%{%f%b%}!%{%B%F{cyan}%}%!%{%B%F{$linecolor}%}├─┘%{%f%k%b%}'
PS2='%{%B%F{$linecolor}%}└─┤%{%B%F{red}%}%_%{%B%F{$linecolor}%}.. '

}

setprompt

