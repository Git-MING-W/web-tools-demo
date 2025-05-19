#!/bin/bash

modprobe macvlan
#依需求調整第１台 192.168.1.2，第２台 192.168.1.４，第３台  192.168.1.6
docker network create --driver macvlan --subnet 192.168.1.0/24 --gateway 192.168.1.2 --ip-range 192.168.1.0/24 --opt parent=__REPLACE_WITH_INTERFACE__ vlan0001

ip link set __REPLACE_WITH_INTERFACE__  promisc on

ip link add vlan0001 link __REPLACE_WITH_INTERFACE__ type macvlan  mode bridge

ip link set vlan0001 up

ifconfig vlan0001 192.168.1.2 netmask 255.255.255.0