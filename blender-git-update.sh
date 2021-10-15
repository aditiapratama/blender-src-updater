# !/bin/sh
#
#: Title       : Blender-update-ubuntu
#: Author      : Aditia A. Pratama < aditia -dot- ap -at- gmail.com >
#: License     : GPL
#  version 1.5
#  Changelog
#  ===========
#  - Update to latest Blender 2.92
#  - Update to latest Blender 2.90.1
#  - sudo apt install libnotify-bin

# Main Repo
: ${BLENDERGITREPO="$HOME/blender-git"}
: ${BLENDERGITSOURCE="$HOME/blender-git/blender"}

# : ${BPYBUILD="$BLENDERGITREPO/build_windows_Bpy_x64_vc16_Release/bin/Release"}
: ${BLENDERGITBUILD="$BLENDERGITREPO/build_linux_full/bin"}
: ${BLENDERUPDATER="/home/aditia/Workspaces/git/BlenderUpdaterCLI"}
: ${PYTHONDIR="/home/aditia/.pyenv/versions/3.9.6/lib/python3.9"}
: ${LIB="/$BLENDERGITREPO/lib/linux_centos7_x86_64"}

# User
: ${USERNAME="Aditia A. Pratama"}
: ${EMAIL="aditia.ap@gmail.com"}

# Blender Main
: ${VERSION_MAIN="2.91.2"}
: ${CONFIG_MAIN="2.91"}
: ${BLENDER_MAIN="/opt/blender/$VERSION_MAIN"}

# Blender RC
: ${VERSION_RC="2.93.6"}
: ${CONFIG_RC="2.93"}
: ${BLENDER_RC="/opt/blender/$VERSION_RC"}

# Blender 2.8 LTS
: ${VERSION_LTS_01="2.83.17"}
: ${CONFIG_LTS_01="2.83"}
: ${BLENDER_LTS_01="/opt/blender/$VERSION_LTS_01"}

# Blender 2.9 LTS
: ${VERSION_LTS_02="2.93.5"}
: ${CONFIG_LTS_02="2.93"}
: ${BLENDER_LTS_02="/opt/blender/$VERSION_LTS_02"}

# Blender GIT
: ${VERSION_GIT="3.0.0"}
: ${CONFIG_GIT="3.0"}
: ${BLENDER_GIT="/opt/blender/$VERSION_GIT"}

# default is nothing, clean for clean up build
: ${BUILDOPTION="full"}

########
# CORE #
########
numCores=$(($(cat /proc/cpuinfo | grep processor | wc -l)))

_download_alpha_build() {
    res1=$(date +%s.%N)
    notify-send "Start update Blender from Buildbot"
    if [ -d "$BLENDERGITBUILD/$CONFIG_GIT/scripts/addons_contrib" ]; then
        rm -rf $BLENDERGITBUILD/$CONFIG_GIT/scripts/addons_contrib
    # Will enter here if $DIRECTORY exists, even if it contains spaces
    fi
    pyenv exec python $BLENDERUPDATER/BlenderUpdaterCLI.py -p $BLENDER_RC -n -b $VERSION_RC
    notify-send "Blender Alpha from Buildbot Updated"

    res2=$(date +%s.%N)
    dt=$(echo "$res2 - $res1" | bc)
    dd=$(echo "$dt/86400" | bc)
    dt2=$(echo "$dt-86400*$dd" | bc)
    dh=$(echo "$dt2/3600" | bc)
    dt3=$(echo "$dt2-3600*$dh" | bc)
    dm=$(echo "$dt3/60" | bc)
    ds=$(echo "$dt3-60*$dm" | bc)

    printf "Download Alpha Build Total Time: %d:%02d:%02d:%02.4f\n" $dd $dh $dm $ds
}

_download_build() {
    res1=$(date +%s.%N)
    notify-send "Start update Blender from Buildbot"
    if [ -d "$BLENDER_BETA/$CONFIG_BETA/scripts/addons_contrib" ]; then
        rm -rf $BLENDER_BETA/$CONFIG_BETA/scripts/addons_contrib
    # Will enter here if $DIRECTORY exists, even if it contains spaces
    fi
    python $BLENDERUPDATER/BlenderUpdaterCLI.py -p $BLENDER_BETA -n -b $VERSION_BETA
    notify-send "Blender from Buildbot Updated"

    res2=$(date +%s.%N)
    dt=$(echo "$res2 - $res1" | bc)
    dd=$(echo "$dt/86400" | bc)
    dt2=$(echo "$dt-86400*$dd" | bc)
    dh=$(echo "$dt2/3600" | bc)
    dt3=$(echo "$dt2-3600*$dh" | bc)
    dm=$(echo "$dt3/60" | bc)
    ds=$(echo "$dt3-60*$dm" | bc)

    printf "Download Build Total Time: %d:%02d:%02d:%02.4f\n" $dd $dh $dm $ds
}
_update_sources() {
    #Blender Main & Submodule Update
    res1=$(date +%s.%N)

    cd $BLENDERGITSOURCE
    notify-send "Now updating Blender Source Code"
    # git stash
    # git fetch -p
    # git reset --hard
    # git pull --rebase
    # git submodule foreach git stash
    # git submodule foreach git fetch -p
    # git submodule foreach git reset --hard
    # git submodule foreach git pull --rebase origin master
    make update
    notify-send "Blender Source Code Updated"

    clear

    res2=$(date +%s.%N)
    dt=$(echo "$res2 - $res1" | bc)
    dd=$(echo "$dt/86400" | bc)
    dt2=$(echo "$dt-86400*$dd" | bc)
    dh=$(echo "$dt2/3600" | bc)
    dt3=$(echo "$dt2-3600*$dh" | bc)
    dm=$(echo "$dt3/60" | bc)
    ds=$(echo "$dt3-60*$dm" | bc)

    printf "Update Source Code Total Time: %d:%02d:%02d:%02.4f\n" $dd $dh $dm $ds
}

_update_lib() {
    res1=$(date +%s.%N)

    cd $LIB
    notify-send "Now updating Blender Library"
    svn cleanup
    svn update
    notify-send "Blender Library Updated"
    res2=$(date +%s.%N)
    dt=$(echo "$res2 - $res1" | bc)
    dd=$(echo "$dt/86400" | bc)
    dt2=$(echo "$dt-86400*$dd" | bc)
    dh=$(echo "$dt2/3600" | bc)
    dt3=$(echo "$dt2-3600*$dh" | bc)
    dm=$(echo "$dt3/60" | bc)
    ds=$(echo "$dt3-60*$dm" | bc)

    printf "Update Library Total Time: %d:%02d:%02d:%02.4f\n" $dd $dh $dm $ds
}

_update_view_log() {
    cd $BLENDERGITSOURCE
    branchname=$(git symbolic-ref --short -q HEAD)
    blenderlog=$(git log --pretty=format:'%cn | [%h](https://developer.blender.org/rB%h) | %s | *%cr*' -30)
    commithash=$(git log --pretty=format:'%h' -30)
    commitname=$(git log --pretty=format:'%cn' -30)
    commitsubject=$(git log --pretty=format:'%s' -30)
    committime=$(git log --pretty=format:'%cr' -30)
    NOW=$(date +"%A, %B  %-d$($BLENDERGITREPO/date_ordinal) %Y at %I:%M %p")
    echo "<div class='container' markdown='1'>" >$BLENDERGITREPO/log.md
    echo "##### <i class='fa fa-calendar' aria-hidden='true'></i> Generated on '$NOW'" >>$BLENDERGITREPO/log.md
    echo "# BLENDER Branch : ![Blender][logo] *$branchname*" >>$BLENDERGITREPO/log.md
    echo '[logo]:webassets/img/square/blender_icon_32x32.png "Logo Blender"' >>$BLENDERGITREPO/log.md
    echo "" >>$BLENDERGITREPO/log.md
    echo "user | hash | comment | time" >>$BLENDERGITREPO/log.md
    echo "--- | --- | --- | ---" >>$BLENDERGITREPO/log.md
    # git log --pretty=format:'%cn | [%h](https://developer.blender.org/rB%h) | %s | *%cr*' -30 >> $HOME/blender-git/log.md
    git log --pretty=format:'%cn | <a href="https://developer.blender.org/rB%h" target="_blank"><code>%h</code><i class="fa fa-external-link" aria-hidden="true"></i></a> | %s | *%cr*' -30 >>$BLENDERGITREPO/log.md
    # echo $blenderlog >> $HOME/blender-git/log.md
    # echo $commitname' | <a href="https://developer.blender.org/rB"'$commithash' target="_blank"><i class="fa fa-external-link" aria-hidden="true"></i><code>'$commithash'</code></a> | ' $commitsubject ' | <i>' $committime '</i>' >> $HOME/blender-git/log.md
    echo "" >>$BLENDERGITREPO/log.md
    echo "</div>" >>$BLENDERGITREPO/log.md
    echo "<div class='container' markdown='1'>" >>$BLENDERGITREPO/log.md
    cd $BLENDERGITSOURCE/release/scripts/addons/ && echo "" >>$BLENDERGITREPO/log.md
    echo "" >>$BLENDERGITREPO/log.md
    echo "### ADDONS " >>$BLENDERGITREPO/log.md
    #echo "-------------------------------" >> $BLENDERGITREPO/log.md
    echo "" >>$BLENDERGITREPO/log.md
    echo "user | hash | comment | time" >>$BLENDERGITREPO/log.md
    echo "--- | --- | --- | ---" >>$BLENDERGITREPO/log.md
    git log --pretty=format:'%cn | <a href="https://developer.blender.org/rBA%h" target="_blank"><code>%h</code><i class="fa fa-external-link" aria-hidden="true"></i></a> | %s | *%cr*' -15 >>$BLENDERGITREPO/log.md
    echo "" >>$BLENDERGITREPO/log.md
    echo "</div>" >>$BLENDERGITREPO/log.md
    echo "<div class='container' markdown='1'>" >>$BLENDERGITREPO/log.md
    cd $BLENDERGITSOURCE/release/scripts/addons_contrib/ && echo "" >>$BLENDERGITREPO/log.md
    echo "### ADDONS CONTRIB" >>$BLENDERGITREPO/log.md
    #echo "-------------------------------" >> $BLENDERGITREPO/log.md
    echo "" >>$BLENDERGITREPO/log.md
    echo "user | hash | comment | time" >>$BLENDERGITREPO/log.md
    echo "--- | --- | --- | ---" >>$BLENDERGITREPO/log.md
    git log --pretty=format:'%cn | <a href="https://developer.blender.org/rBAC%h" target="_blank"><code>%h</code><i class="fa fa-external-link" aria-hidden="true"></i></a> | %s | *%cr*' -15 >>$BLENDERGITREPO/log.md
    echo "" >>$BLENDERGITREPO/log.md
    echo "</div>" >>$BLENDERGITREPO/log.md
    echo "<div class='container' markdown='1'>" >>$BLENDERGITREPO/log.md
    cd $LIB && echo "" >>$BLENDERGITREPO/log.md
    echo "### BLENDER LIBS " >>$BLENDERGITREPO/log.md
    echo "" >>$BLENDERGITREPO/log.md
    echo "user | hash | comment | time " >>$BLENDERGITREPO/log.md
    echo "--- | --- | --- | ---" >>$BLENDERGITREPO/log.md
    svn log -l15 | $BLENDERGITREPO/svn_short_log | awk '{gsub(/\/r/,"/rBL")}1' >> $BLENDERGITREPO/log.md
    echo "" >>$BLENDERGITREPO/log.md
    echo "</div>" >>$BLENDERGITREPO/log.md
}

_view_log() {
    pyenv exec markdown2 -x tables,markdown-in-html $BLENDERGITREPO/log.md >$BLENDERGITREPO/log.html
    cat $BLENDERGITREPO/header.html $BLENDERGITREPO/log.html > $BLENDERGITREPO/report.html
    cd $BLENDERGITREPO
    xdg-open report.html >/dev/null 2>&1
    notify-send "Now displaying Log Report"
}

_build_full() {
    res1=$(date +%s.%N)

    cd $BLENDERGITSOURCE
    notify-send "Now Building Blender from Sources"
    rm -rf $BLENDERGITBUILD/$CONFIG_GIT/scripts/addons_contrib
    make $BUILDOPTION 2>&1 | tee $BLENDERGITREPO/BuildLogs.txt
    notify-send "Building Blender Completed"

    clear

    res2=$(date +%s.%N)
    dt=$(echo "$res2 - $res1" | bc)
    dd=$(echo "$dt/86400" | bc)
    dt2=$(echo "$dt-86400*$dd" | bc)
    dh=$(echo "$dt2/3600" | bc)
    dt3=$(echo "$dt2-3600*$dh" | bc)
    dm=$(echo "$dt3/60" | bc)
    ds=$(echo "$dt3-60*$dm" | bc)

    printf "Build Blender Total Time: %d:%02d:%02d:%02.4f\n" $dd $dh $dm $ds
}

_copy_addons() {
    res1=$(date +%s.%N)

    notify-send "Copying Addons Files"

    # Remove all addons

    cd $BLENDER_MAIN/$CONFIG_MAIN/scripts/addons/
    rm -rf $(ls -1 --ignore=cycles .)
    rm -rf $BLENDER_MAIN/$CONFIG_MAIN/scripts/addons_contrib

    cd $BLENDER_RC/$CONFIG_RC/scripts/addons/
    rm -rf $(ls -1 --ignore=cycles .)
    rm -rf $BLENDER_RC/$CONFIG_RC/scripts/addons_contrib

    # Start copying from latest master

    cd $BLENDERGITSOURCE/release/scripts/addons/

    cp -R $(ls -1 --ignore=cycles .) $BLENDER_MAIN/$CONFIG_MAIN/scripts/addons/

    cp -R $(ls -1 --ignore=cycles .) $BLENDER_RC/$CONFIG_RC/scripts/addons/

    cp -R $BLENDERGITSOURCE/release/scripts/addons_contrib $BLENDER_MAIN/$CONFIG_MAIN/scripts/addons_contrib

    cp -R $BLENDERGITSOURCE/release/scripts/addons_contrib $BLENDER_RC/$CONFIG_RC/scripts/addons_contrib

    res2=$(date +%s.%N)
    dt=$(echo "$res2 - $res1" | bc)
    dd=$(echo "$dt/86400" | bc)
    dt2=$(echo "$dt-86400*$dd" | bc)
    dh=$(echo "$dt2/3600" | bc)
    dt3=$(echo "$dt2-3600*$dh" | bc)
    dm=$(echo "$dt3/60" | bc)
    ds=$(echo "$dt3-60*$dm" | bc)

    printf "Copy Addons Files Total Time: %d:%02d:%02d:%02.4f\n" $dd $dh $dm $ds

}

# _copy_workfile() {
    # res1=$(date +%s.%N)
#
    # notify-send "Start update Blender"
    # rm -rf $BLENDER28/$BETAVERSION/scripts/addons_contrib
    # cp -R $BLENDERBUILD/. $BLENDER28
    # notify-send "Blender Updated"
#
    # res2=$(date +%s.%N)
    # dt=$(echo "$res2 - $res1" | bc)
    # dd=$(echo "$dt/86400" | bc)
    # dt2=$(echo "$dt-86400*$dd" | bc)
    # dh=$(echo "$dt2/3600" | bc)
    # dt3=$(echo "$dt2-3600*$dh" | bc)
    # dm=$(echo "$dt3/60" | bc)
    # ds=$(echo "$dt3-60*$dm" | bc)
#
    # printf "Copy Workfiles Total Time: %d:%02d:%02d:%02.4f\n" $dd $dh $dm $ds
# }



_endkey() {
    echo -n "Press [enter] to exit"
    read END
}

#######
# UI  #
#######

clear
echo "BLENDER-UPDATE"
echo "------------------------------------------------------------"
echo ""
echo "   (0) Download Beta Blender Build"
echo "   (1) Update Blender and Lib"
echo "   (2) Update Blender Only"
echo "   (3) Update lib Only"
echo "   (4) view log "
echo "   (5) Build Full "
echo "   (6) Download Alpha Blender Build"
echo "   (7) Exit"
echo ""
echo "------------------------------------------------------------"
echo -n "               Enter your choice (1-4) then press [enter] :"
read mainmenu
echo " "
clear

if [ "$mainmenu" = 1 ]; then
    _update_sources
    _update_lib
    _copy_addons
    _update_view_log
    _view_log
    _endkey

elif [ "$mainmenu" = 2 ]; then
    _update_sources
    _update_view_log
    _view_log
    _endkey

elif [ "$mainmenu" = 3 ]; then
    _update_lib
    _update_view_log
    _view_log
    _endkey

elif [ "$mainmenu" = 4 ]; then
    _update_view_log
    _view_log
    _endkey

elif [ "$mainmenu" = 5 ]; then
    _build_full
    # _copy_workfile
    _endkey

elif [ "$mainmenu" = 6 ]; then
    _download_alpha_build
    _endkey
elif [ "$mainmenu" = 7 ]; then
    echo "Bye ! "

elif [ "$mainmenu" = 0 ]; then
    _download_build
    _endkey

else
    echo "the script couldn't understand your choice, try again..."

fi
