#!/bin/bash

cd $ROSWSS_ROOT

if [ -z "$ROSWSS_ROOT" ]; then
    ROSWSS_ROOT=$(cd `dirname $0`; pwd)
fi

# exit if one of the commands fail
#set -e

# install

# delete old files
echo Cleaning up old workspace files...
for f in .rosinstall* devel build; do
    [ -f $f ] && echo "rm -iv $f" && rm -i $f
    [ -d $f ] && echo "rm -Irv $f" && rm -Ir $f
done
echo

# find an installation of ROS
if [ -z "$ROS_DISTRO" ]; then
    _ROS_DISTROS="fuerte groovy hydro indigo"

    # use basename of the current folder as default ROS distro
    ROS_DISTRO=$(basename $(cd `dirname $0`; pwd))
    for _distro in $_ROS_DISTROS ask; do
        if [ "$_distro" = "$ROS_DISTRO" ]; then break; fi
    done

    if [ "$_distro" = "ask" ]; then
        echo -n "Which ROS distro you want to setup this workspace for ($_ROS_DISTROS)?"
        read ROS_DISTRO
    fi

    if [ ! -r /opt/ros/$ROS_DISTRO/setup.sh ]; then
        echo "Directory /opt/ros/$ROS_DISTRO does not exists!"
        exit 1
    fi

    source /opt/ros/$ROS_DISTRO/setup.sh
    echo
fi

# make sure package dependencies are installed
source $ROSWSS_ROOT/rosinstall/install_scripts/install_package_dependencies.sh

# initialize workspace
if [ ! -f ".rosinstall" ]; then
    wstool init .
fi

# merge rosinstall files from rosinstall/*.rosinstall
for file in $ROSWSS_ROOT/rosinstall/*.rosinstall; do
    filename=$(basename ${file%.*})
    echo "Merging to workspace: '$filename'.rosinstall"
    wstool merge $file -y
done
echo

# update workspace
wstool update
echo

# install dependencies
rosdep update
rosdep install -r --from-path . --ignore-src

# remove symlink to write protected CMakefile and use a copy instead
if [ -f $ROSWSS_ROOT/src/CMakeLists.txt ]; then
  rm $ROSWSS_ROOT/src/CMakeLists.txt
fi
cp /opt/ros/$ROS_DISTRO/share/catkin/cmake/toplevel.cmake $ROSWSS_ROOT/src/CMakeLists.txt

echo

# generate top-level setup.bash
cat >setup.bash <<EOF
#!/bin/bash
# automated generated file
. $ROSWSS_ROOT/devel/setup.bash
EOF

# invoke make for the initial setup
#catkin_make cmake_check_build_system
export ROSWSS_SCRIPTS=$ROSWSS_ROOT/src/workspace_scripts/scripts
. $ROSWSS_SCRIPTS/make.sh
echo

cat << EOF
Try to source your workspace -
Do: source setup.bash
EOF
source setup.bash

cat << EOF
Add line to your .bashrc file:
EOF
echo "source $ROSWSS_ROOT/setup.bash" >> ~/.bashrc

# Initialization successful. Print message and exit.
cat <<EOF

===================================================================
Workspace initialization completed.
You can setup your current shell's environment by entering

    source $ROSWSS_ROOT/setup.bash

or by adding this command to your .bashrc file for automatic setup on each invocation of an interactive shell:

    echo "source $ROSWSS_ROOT/setup.bash" >> ~/.bashrc

You can also modify your workspace config (e.g. for adding additional repositories or
packages) using the wstool command.
===================================================================

EOF

