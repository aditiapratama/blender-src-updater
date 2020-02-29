# !/bin/sh
#
#: Title       : Blender-update-WSL
#: Author      : Aditia A. Pratama < aditia -dot- ap -at- gmail.com >
#: License     : GPL
#  version 1.2
#  Changelog
#  ===========
#  - Update to latest Blender 2.83

: ${BLENDERHOME="/mnt/d/blender-git"}
: ${PYTHONDIR="/mnt/c/Users/aditi/AppData/local/Programs/Python/Python37"}
: ${BLENDER="/mnt/d/blender-git/blender"}
: ${LIBWIN64="/mnt/d/blender-git/lib/win64_vc15"}
: ${USERNAME="Aditia A. Pratama"}
: ${EMAIL="aditia.ap@gmail.com"}
: ${BLENDERMAIN="/mnt/c/Blender"}
: ${BLENDER28="/mnt/c/Blender2.8"}
: ${BLENDERUPDATER="/mnt/d/Apps/BlenderUpdaterCLI"}
: ${BLENDERBUILD="$BLENDERHOME/build_windows_Full_x64_vc16_Release/bin/Release"}
: ${BPYBUILD="$BLENDERHOME/build_windows_Bpy_x64_vc16_Release/bin/Release"}
: ${BLENDERVERSION="2.82"}
: ${BETAVERSION="2.83"}
: ${BLENDERBETA="/mnt/d/BlenderBeta/"}
: ${BLENDERECYCLES="/mnt/d/BlenderEcycles/Release"}
: ${BUILDOPTION="clang"} #default is nothing, clean for clean up build

########
# CORE #
########
numCores=$(($(cat /proc/cpuinfo | grep processor | wc -l)))

_download_build() {
    res1=$(date +%s.%N)

    wsl-notify "Start update Blender from Buildbot"
    if [ -d "$BLENDERBETA/$BETAVERSION/scripts/addons_contrib" ]; then
        rm -rf $BLENDERBETA/$BETAVERSION/scripts/addons_contrib
    # Will enter here if $DIRECTORY exists, even if it contains spaces
    fi
    python3 $BLENDERUPDATER/BlenderUpdaterCLI.py -p $BLENDERBETA -o windows -n -b $BETAVERSION
    wsl-notify "Blender from Buildbot Updated"

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

    cd $BLENDER
    wsl-notify "Now updating Blender Source Code"
    git stash
    git fetch -p
    git reset --hard
    git pull --rebase
    git submodule foreach git stash
    git submodule foreach git fetch -p
    git submodule foreach git reset --hard
    git submodule foreach git pull --rebase origin master
    wsl-notify "Blender Source Code Updated"

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
    wsl-notify "Now updating Blender Library"
    svn cleanup
    svn update
    wsl-notify "Blender Library Updated"
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
    cd $BLENDER
    branchname=$(git symbolic-ref --short -q HEAD)
    blenderlog=$(git log --pretty=format:'%cn | [%h](https://developer.blender.org/rB%h) | %s | *%cr*' -30)
    commithash=$(git log --pretty=format:'%h' -30)
    commitname=$(git log --pretty=format:'%cn' -30)
    commitsubject=$(git log --pretty=format:'%s' -30)
    committime=$(git log --pretty=format:'%cr' -30)
    NOW=$(date +"%A, %B  %-d$($BLENDERHOME/date_ordinal) %Y at %I:%M %p")
    echo "<div class='container' markdown='1'>" >$BLENDERHOME/log.md
    echo "##### <i class='fa fa-calendar' aria-hidden='true'></i> Generated on '$NOW'" >>$BLENDERHOME/log.md
    echo "# BLENDER Branch : ![Blender][logo] *$branchname*" >>$BLENDERHOME/log.md
    echo '[logo]:webassets/img/square/blender_icon_32x32.png "Logo Blender"' >>$BLENDERHOME/log.md
    echo "" >>$BLENDERHOME/log.md
    echo "user | hash | comment | time" >>$BLENDERHOME/log.md
    echo "--- | --- | --- | ---" >>$BLENDERHOME/log.md
    # git log --pretty=format:'%cn | [%h](https://developer.blender.org/rB%h) | %s | *%cr*' -30 >> $HOME/blender-git/log.md
    git log --pretty=format:'%cn | <a href="https://developer.blender.org/rB%h" target="_blank"><code>%h</code><i class="fa fa-external-link" aria-hidden="true"></i></a> | %s | *%cr*' -30 >>$BLENDERHOME/log.md
    # echo $blenderlog >> $HOME/blender-git/log.md
    # echo $commitname' | <a href="https://developer.blender.org/rB"'$commithash' target="_blank"><i class="fa fa-external-link" aria-hidden="true"></i><code>'$commithash'</code></a> | ' $commitsubject ' | <i>' $committime '</i>' >> $HOME/blender-git/log.md
    echo "" >>$BLENDERHOME/log.md
    echo "</div>" >>$BLENDERHOME/log.md
    echo "<div class='container' markdown='1'>" >>$BLENDERHOME/log.md
    cd $BLENDER/release/scripts/addons/ && echo "" >>$BLENDERHOME/log.md
    echo "" >>$BLENDERHOME/log.md
    echo "### ADDONS " >>$BLENDERHOME/log.md
    #echo "-------------------------------" >> $BLENDERHOME/log.md
    echo "" >>$BLENDERHOME/log.md
    echo "user | hash | comment | time" >>$BLENDERHOME/log.md
    echo "--- | --- | --- | ---" >>$BLENDERHOME/log.md
    git log --pretty=format:'%cn | <a href="https://developer.blender.org/rBA%h" target="_blank"><code>%h</code><i class="fa fa-external-link" aria-hidden="true"></i></a> | %s | *%cr*' -15 >>$BLENDERHOME/log.md
    echo "" >>$BLENDERHOME/log.md
    echo "</div>" >>$BLENDERHOME/log.md
    echo "<div class='container' markdown='1'>" >>$BLENDERHOME/log.md
    cd $BLENDER/release/scripts/addons_contrib/ && echo "" >>$BLENDERHOME/log.md
    echo "### ADDONS CONTRIB" >>$BLENDERHOME/log.md
    #echo "-------------------------------" >> $BLENDERHOME/log.md
    echo "" >>$BLENDERHOME/log.md
    echo "user | hash | comment | time" >>$BLENDERHOME/log.md
    echo "--- | --- | --- | ---" >>$BLENDERHOME/log.md
    git log --pretty=format:'%cn | <a href="https://developer.blender.org/rBAC%h" target="_blank"><code>%h</code><i class="fa fa-external-link" aria-hidden="true"></i></a> | %s | *%cr*' -15 >>$BLENDERHOME/log.md
    echo "" >>$BLENDERHOME/log.md
    echo "</div>" >>$BLENDERHOME/log.md
    echo "<div class='container' markdown='1'>" >>$BLENDERHOME/log.md
    cd $LIBWIN64 && echo "" >>$BLENDERHOME/log.md
    echo "### BLENDER WIN64 LIBS " >>$BLENDERHOME/log.md
    echo "" >>$BLENDERHOME/log.md
    echo "user | hash | comment | time " >>$BLENDERHOME/log.md
    echo "--- | --- | --- | ---" >>$BLENDERHOME/log.md
    svn log -l15 | $BLENDERHOME/svn_short_log | awk '{gsub(/\/r/,"/rBL")}1' >> $BLENDERHOME/log.md
    echo "" >>$BLENDERHOME/log.md
    echo "</div>" >>$BLENDERHOME/log.md
}

_view_log() {
    markdown2 -x tables,markdown-in-html $BLENDERHOME/log.md >$BLENDERHOME/log.html
    cat $BLENDERHOME/header.html $BLENDERHOME/log.html > $BLENDERHOME/report.html
    cd $BLENDERHOME
    # xdg-open report.html >/dev/null 2>&1
    cmd.exe /c report.html
    wsl-notify "Now displaying Log Report"
}

_build_full() {
    res1=$(date +%s.%N)

    cd $BLENDER
    wsl-notify "Now Building Blender from Sources"
    rm -rf $BLENDERBUILD/$BETAVERSION/scripts/addons_contrib
    cmd.exe /c make.bat full $BUILDOPTION 2>&1 | tee $BLENDERHOME/BuildLogs.txt
    wsl-notify "Building Blender Completed"

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

    wsl-notify "Copying Addons Files"

    # Remove all addons

    cd $BLENDERECYCLES/$BLENDERVERSION/scripts/addons/
    rm -rf $(ls -1 --ignore=cycles --ignore=AI_denoise_addon.py .)
    rm -rf $BLENDERECYCLES/$BLENDERVERSION/scripts/addons_contrib

    cd $BLENDERMAIN/$BLENDERVERSION/scripts/addons/
    rm -rf $(ls -1 --ignore=cycles .)
    rm -rf $BLENDERMAIN/$BLENDERVERSION/scripts/addons_contrib

    cd $BLENDERBETA/$BETAVERSION/scripts/addons/
    rm -rf $(ls -1 --ignore=cycles .)
    rm -rf $BLENDERBETA/$BETAVERSION/scripts/addons_contrib

    # Start copying from latest master

    cd $BLENDER/release/scripts/addons/

    cp -R $(ls -1 --ignore=cycles .) $BLENDERECYCLES/$BLENDERVERSION/scripts/addons/

    cp -R $(ls -1 --ignore=cycles .) $BLENDERMAIN/$BLENDERVERSION/scripts/addons/

    cp -R $(ls -1 --ignore=cycles .) $BLENDERBETA/$BETAVERSION/scripts/addons/

    cp -R $BLENDER/release/scripts/addons_contrib $BLENDERECYCLES/$BLENDERVERSION/scripts/addons_contrib

    cp -R $BLENDER/release/scripts/addons_contrib $BLENDERMAIN/$BLENDERVERSION/scripts/addons_contrib

    cp -R $BLENDER/release/scripts/addons_contrib $BLENDERBETA/$BETAVERSION/scripts/addons_contrib

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

    wsl-notify "Start update Blender"
    rm -rf $BLENDER28/$BETAVERSION/scripts/addons_contrib
    cp -R $BLENDERBUILD/. $BLENDER28
    wsl-notify "Blender Updated"

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

    cd $BLENDER
    wsl-notify "Now Building BPY from Sources"
    cmd.exe /c make.bat bpy $BUILDOPTION 2>&1 | tee $BLENDERHOME/BuildBPYLogs.txt
    wsl-notify "Building BPY Completed"

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

    wsl-notify "Start update BPY $BETAVERSION"
    rm -rf $PYTHONDIR/$BETAVERSION
    cp -R $BPYBUILD/$BETAVERSION $PYTHONDIR/$BETAVERSION
    find $BPYBUILD -type f \( -iname "*.dll" ! -iname "python37.dll" \) -exec cp -uR {} $PYTHONDIR/Lib/site-packages/ \;
    cp -uR $BPYBUILD/bpy.pyd $PYTHONDIR/Lib/site-packages
    wsl-notify "BPY $BETAVERSION Updated"

    res2=$(date +%s.%N)
    dt=$(echo "$res2 - $res1" | bc)
    dd=$(echo "$dt/86400" | bc)
    dt2=$(echo "$dt-86400*$dd" | bc)
    dh=$(echo "$dt2/3600" | bc)
    dt3=$(echo "$dt2-3600*$dh" | bc)
    dm=$(echo "$dt3/60" | bc)
    ds=$(echo "$dt3-60*$dm" | bc)

    printf "Copy BPY $BETAVERSION Modules Total Time: %d:%02d:%02d:%02.4f\n" $dd $dh $dm $ds
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
echo "   (0) Download Latest Blender Build"
echo "   (1) Update Blender and Lib Win64"
echo "   (2) Update Blender Only"
echo "   (3) Update lib Win64 Only"
echo "   (4) view log "
echo "   (5) Build Full "
echo "   (6) Build Python Module "
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
    _build_bpy
    _copy_bpy_module
    _endkey

elif [ "$mainmenu" = 7 ]; then
    echo "Bye ! "

elif [ "$mainmenu" = 0 ]; then
    _download_build
    _endkey

else
    echo "the script couldn't understand your choice, try again..."

fi
