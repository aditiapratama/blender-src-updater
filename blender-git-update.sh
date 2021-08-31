# !/bin/sh
#
#: Title       : Blender-update-WSL
#: Author      : Aditia A. Pratama < aditia -dot- ap -at- gmail.com >
#: License     : GPL
#  version 1.2
#  Changelog
#  ===========
#  - Update to latest Blender 2.83
###  Blender Repo
: ${BLENDERGITREPO="/mnt/d/blender-git"}
: ${BLENDERGITSOURCE="/mnt/d/blender-git/blender"}
: ${BPYBUILD="$BLENDERGITREPO/build_windows_Bpy_x64_vc16_Release/bin/Release"}
: ${BLENDERGITBUILD="$BLENDERGITREPO/build_windows_Full_x64_vc16_Release/bin/Release"}
: ${BLENDERUPDATER="/mnt/d/Apps/BlenderUpdaterCLI"}
: ${PYTHONDIR="/mnt/c/Users/aditi/AppData/local/Programs/Python/Python37"}
: ${LIBWIN64="/mnt/d/blender-git/lib/win64_vc15"}
# User and Email
: ${USERNAME="Aditia A. Pratama"}
: ${EMAIL="aditia.ap@gmail.com"}
# Blender Main
: ${BLENDER_MAIN="/mnt/c/Blender"}
: ${VERSION_MAIN="2.91.2"}
: ${CONFIG_MAIN="2.91"}
# Blender Beta
: ${BLENDER_BETA="/mnt/c/BlenderBeta/"}
: ${VERSION_BETA="2.93.1"}
: ${CONFIG_BETA="2.93"}
# Blender LTS
: ${BLENDER_LTS="/mnt/c/BlenderLTS"}
: ${VERSION_LTS="2.83.16"}
: ${CONFIG_LTS="2.83"}
# Blender ECycles Beta
: ${ECYCLES_BETA="/mnt/d/BlenderEcycles/Release"}
# Blender GIT
: ${BLENDER_GIT="/mnt/d/BlenderMaster"}
: ${VERSION_GIT="2.93.4"}
: ${CONFIG_GIT="2.93"}
: ${BUILDOPTION="clang"} #default is nothing, clean for clean up build
: ${LOGO="D:\\blender-git\\webassets\\img\\square\\blender_icon_64x64.png"}
########
# CORE #
########
numCores=$(($(cat /proc/cpuinfo | grep processor | wc -l)))

_download_alpha_build() {
    res1=$(date +%s.%N)
    notify-send --icon $LOGO --category "Blender Update:" "Start update Blender Alpha from Buildbot"
    if [ -d "$BLENDER_GIT/$CONFIG_GIT/scripts/addons_contrib" ]; then
        rm -rf $BLENDER_GIT/$CONFIG_GIT/scripts/addons_contrib
    # Will enter here if $DIRECTORY exists, even if it contains spaces
    fi
    python $BLENDERUPDATER/BlenderUpdaterCLI.py -p $BLENDER_GIT -o windows -b $VERSION_GIT
    notify-send --icon $LOGO --category "Blender Update:" "Blender Alpha from Buildbot Updated"

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

    notify-send --icon $LOGO --category "Blender Update:" "Start update Blender from Buildbot"
    if [ -d "$BLENDER_BETA/$CONFIG_BETA/scripts/addons_contrib" ]; then
        rm -rf $BLENDER_BETA/$CONFIG_BETA/scripts/addons_contrib
    # Will enter here if $DIRECTORY exists, even if it contains spaces
    fi
    python3 $BLENDERUPDATER/BlenderUpdaterCLI.py -p $BLENDER_BETA -o windows -n -b $VERSION_BETA
    notify-send --icon $LOGO --category "Blender Update:" "Blender from Buildbot Updated"

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
    notify-send --icon $LOGO --category "Blender Update:" "Now updating Blender Source Code"
    git stash
    git fetch -p
    git reset --hard
    git pull --rebase
    git submodule foreach git stash
    git submodule foreach git fetch -p
    git submodule foreach git reset --hard
    git submodule foreach git pull --rebase origin master
    notify-send --icon $LOGO --category "Blender Update:" "Blender Source Code Updated"

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

    cd $LIBWIN64
    notify-send --icon $LOGO --category "Blender Update:" "Now updating Blender Library"
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
    cd $LIBWIN64 && echo "" >>$BLENDERGITREPO/log.md
    echo "### BLENDER WIN64 LIBS " >>$BLENDERGITREPO/log.md
    echo "" >>$BLENDERGITREPO/log.md
    echo "user | hash | comment | time " >>$BLENDERGITREPO/log.md
    echo "--- | --- | --- | ---" >>$BLENDERGITREPO/log.md
    svn log -l15 | $BLENDERGITREPO/svn_short_log | awk '{gsub(/\/r/,"/rBL")}1' >> $BLENDERGITREPO/log.md
    echo "" >>$BLENDERGITREPO/log.md
    echo "</div>" >>$BLENDERGITREPO/log.md
}

_view_log() {
    markdown2 -x tables,markdown-in-html $BLENDERGITREPO/log.md >$BLENDERGITREPO/log.html
    cat $BLENDERGITREPO/header.html $BLENDERGITREPO/log.html > $BLENDERGITREPO/report.html
    cd $BLENDERGITREPO
    # xdg-open report.html >/dev/null 2>&1
    cmd.exe /c report.html
    notify-send --icon $LOGO --category "Blender Update:" "Now displaying Log Report"
}

_build_full() {
    res1=$(date +%s.%N)

    cd $BLENDERGITSOURCE
    notify-send "Now Building Blender from Sources"
    rm -rf $BLENDERGITBUILD/$CONFIG_GIT/scripts/addons_contrib
    cmd.exe /c make.bat full $BUILDOPTION 2>&1 | tee $BLENDERGITREPO/BuildLogs.txt
    notify-send --icon $LOGO --category "Blender Update:" "Building Blender Completed"

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

    notify-send --icon $LOGO --category "Blender Update:" "Copying Addons Files"

    # Remove all addons

    # cd $BLENDERECYCLES/$CONFIGVERLTS/scripts/addons/
    # rm -rf $(ls -1 --ignore=cycles --ignore=AI_denoise_addon.py .)
    # rm -rf $BLENDERECYCLES/$CONFIGVERLTS/scripts/addons_contrib

    cd $BLENDER_MAIN/$CONFIG_MAIN/scripts/addons/
    rm -rf $(ls -1 --ignore=cycles .)
    rm -rf $BLENDER_MAIN/$CONFIG_MAIN/scripts/addons_contrib

    cd $BLENDER_BETA/$CONFIG_BETA/scripts/addons/
    rm -rf $(ls -1 --ignore=cycles .)
    rm -rf $BLENDER_BETA/$CONFIG_BETA/scripts/addons_contrib

    # Start copying from latest master

    cd $BLENDERGITSOURCE/release/scripts/addons/

    # cp -R $(ls -1 --ignore=cycles .) $BLENDERECYCLES/$CONFIGVERLTS/scripts/addons/

    cp -R $(ls -1 --ignore=cycles .) $BLENDER_MAIN/$CONFIG_MAIN/scripts/addons/

    cp -R $(ls -1 --ignore=cycles .) $BLENDER_BETA/$CONFIG_BETA/scripts/addons/

    # cp -R $BLENDER/release/scripts/addons_contrib $BLENDERECYCLES/$CONFIGVERBETA/scripts/addons_contrib

    cp -R $BLENDERGITSOURCE/release/scripts/addons_contrib $BLENDER_MAIN/$CONFIG_MAIN/scripts/addons_contrib

    cp -R $BLENDERGITSOURCE/release/scripts/addons_contrib $BLENDER_BETA/$CONFIG_BETA/scripts/addons_contrib

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

_copy_workfile() {
    res1=$(date +%s.%N)

    notify-send --icon $LOGO --category "Blender Update:" "Start update Blender"
    rm -rf $BLENDER_MAIN/$CONFIG_MAIN/scripts/addons_contrib
    cp -R $BLENDERGITBUILD/. $BLENDER_GIT
    notify-send --icon $LOGO --category "Blender Update:" "Blender Updated"

    res2=$(date +%s.%N)
    dt=$(echo "$res2 - $res1" | bc)
    dd=$(echo "$dt/86400" | bc)
    dt2=$(echo "$dt-86400*$dd" | bc)
    dh=$(echo "$dt2/3600" | bc)
    dt3=$(echo "$dt2-3600*$dh" | bc)
    dm=$(echo "$dt3/60" | bc)
    ds=$(echo "$dt3-60*$dm" | bc)

    printf "Copy Workfiles Total Time: %d:%02d:%02d:%02.4f\n" $dd $dh $dm $ds
}

_build_bpy() {
    res1=$(date +%s.%N)

    cd $BLENDERGITSOURCE
    notify-send --icon $LOGO --category "Blender Update:" "Now Building BPY from Sources"
    cmd.exe /c make.bat bpy $BUILDOPTION 2>&1 | tee $BLENDERGITREPO/BuildBPYLogs.txt
    notify-send --icon $LOGO --category "Blender Update:" "Building BPY Completed"

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

_copy_bpy_module() {
    res1=$(date +%s.%N)

    notify-send --icon $LOGO --category "Blender Update:" "Start update BPY $VERSION_GIT"
    rm -rf $PYTHONDIR/$CONFIG_GIT
    cp -R $BPYBUILD/$CONFIG_GIT $PYTHONDIR/$CONFIG_GIT
    find $BPYBUILD -type f \( -iname "*.dll" ! -iname "python37.dll" \) -exec cp -uR {} $PYTHONDIR/Lib/site-packages/ \;
    cp -uR $BPYBUILD/bpy.pyd $PYTHONDIR/Lib/site-packages
    notify-send --icon $LOGO --category "Blender Update:" "BPY $VERSION_GIT Updated"

    res2=$(date +%s.%N)
    dt=$(echo "$res2 - $res1" | bc)
    dd=$(echo "$dt/86400" | bc)
    dt2=$(echo "$dt-86400*$dd" | bc)
    dh=$(echo "$dt2/3600" | bc)
    dt3=$(echo "$dt2-3600*$dh" | bc)
    dm=$(echo "$dt3/60" | bc)
    ds=$(echo "$dt3-60*$dm" | bc)

    printf "Copy BPY $VERSION_GIT Modules Total Time: %d:%02d:%02d:%02.4f\n" $dd $dh $dm $ds
}

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
echo "   (1) Update Blender and Lib Win64"
echo "   (2) Update Blender Only"
echo "   (3) Update lib Win64 Only"
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
    _copy_workfile
    _endkey

elif [ "$mainmenu" = 6 ]; then
    _download_alpha_build
    # _build_bpy
    # _copy_bpy_module
    _endkey

elif [ "$mainmenu" = 7 ]; then
    echo "Bye ! "

elif [ "$mainmenu" = 0 ]; then
    _download_build
    _endkey

else
    echo "the script couldn't understand your choice, try again..."

fi
