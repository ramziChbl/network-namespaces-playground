#!/bin/bash

# Delete bridge
ip link set dev br-playground down
brctl delbr br-playground

# Delete namespaces
ip netns delete red
ip netns delete blue



