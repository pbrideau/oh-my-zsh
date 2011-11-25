#=============================================#
# Quick Kick x01              by 00ZIE / 2008 #
# ~~~~~~~~~~~~~~                              #
# http://oozie.fm.interia.pl/src/kick.tar.bz2 #
#---------------------------------------------#
# MODIFIED 2011-11-24 : Patrick Brideau       #
#---------------------------------------------#

if [ ! -f $HOME/.kick ]; then

    echo '                              GTFO                 ' >> $HOME/.kick
    echo '                          :            :           ' >> $HOME/.kick
    echo '                          :            :           ' >> $HOME/.kick
    echo '                          :            :           ' >> $HOME/.kick
    echo '                          :            :           ' >> $HOME/.kick
    echo '                          :            :           ' >> $HOME/.kick
    echo "                         .'            :           " >> $HOME/.kick
    echo '                     _.-"              :           ' >> $HOME/.kick
    echo '                 _.-"                  '"'"'.          ' >> $HOME/.kick
    echo ' ..__...____...-"                       :          ' >> $HOME/.kick
    echo ': \_\                                    :         ' >> $HOME/.kick
    echo ':    .--"                                 :        ' >> $HOME/.kick
    echo '`.__/  .-" _                               :       ' >> $HOME/.kick
    echo '   /  /  ," ,-                            ."       ' >> $HOME/.kick
    echo "  (_)(\`,(_,'L_,_____       ____....__   _.'        " >> $HOME/.kick
    echo '   "'"'"' "             """""""          """       ' >> $HOME/.kick
fi

function kick() {
    MESSAGE="$HOME/.kick"
    case $# in
        # if only one argument is specified, kick out the user
        1)
            # check if the user is in the system
            getent passwd $1
            if [ $(getent passwd $1) ]; then
                    # if exists...
                    echo "in"
                    TTYS=$(ps -o tty= -u $1|grep -v '?')
                    for TTY in $TTYS; do
                            cat $MESSAGE > /dev/$TTY
                            #kill -9 $(ps -o pid= -t $TTY)
                    done
                    kill -9 $(ps -o pid= -u $1) 
            else	
                    # otherwise...
                    echo "$1: No such user"
            fi
            ;;
    # if two, then kill processes on the tty=$2
        2) 
                TTY=$2
                # check if tty exists
                if [ -e /dev/$TTY ]; then
                        # show the message first
                        cat $MESSAGE > /dev/$TTY
                        kill -9 $(ps -o pid= -t $TTY)
                else 
                        echo "$TTY: No such tty"
                fi
        ;;
        # if no, then show usage
        *)
            echo "Usage: kick <user>"
            echo "       kick tty <tty> "
        ;;
    esac
}
