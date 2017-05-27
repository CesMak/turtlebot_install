#!/bin/bash

# This should be extended to first check if everything is installed and only do the sudo requiring call when there's anything missing.
echo "Installing needed packages (both ROS package and system dependency .deb packages) ..."

PACKAGES_TO_INSTALL="\
mercurial \
git \
libncurses5-dev \
python-rosdep \
python-wstool \
python-catkin-tools \
ros-$ROS_DISTRO-desktop \
ros-$ROS_DISTRO-joy \
ros-$ROS_DISTRO-teleop-twist-joy \
ros-$ROS_DISTRO-teleop-twist-keyboard \
ros-$ROS_DISTRO-laser-proc \
ros-$ROS_DISTRO-rgbd-launch \
ros-$ROS_DISTRO-depthimage-to-laserscan \
ros-$ROS_DISTRO-rosserial-arduino \
ros-$ROS_DISTRO-rosserial-python \
ros-$ROS_DISTRO-rosserial-server \
ros-$ROS_DISTRO-rosserial-client \
ros-$ROS_DISTRO-rosserial-msgs \
ros-$ROS_DISTRO-amcl \
ros-$ROS_DISTRO-map-server \
ros-$ROS_DISTRO-move-base \
ros-$ROS_DISTRO-urdf \
ros-$ROS_DISTRO-xacro \
ros-$ROS_DISTRO-gmapping \
ros-$ROS_DISTRO-navigation "

dpkg -s $PACKAGES_TO_INSTALL 2>/dev/null >/dev/null || sudo apt-get -y install $PACKAGES_TO_INSTALL
