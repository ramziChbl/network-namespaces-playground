#!/bin/bash

# Create 'blue' namespace
ip netns add blue

# Set up loopback interface
ip netns exec blue ip link set dev lo up

# Create veth pair
ip link add veth0 type veth peer name vethblue

# Move veth0 to namespace
ip link set veth0 netns blue

# Add ip address to veth0 in namespace
ip netns exec blue ip addr add 10.1.1.1/24 dev veth0

# Power on the veths
ip netns exec blue ip link set dev veth0 up
ip link set dev vethblue up


# Create 'red' namespace
ip netns add red

# Set up loopback interface
ip netns exec red ip link set dev lo up

# Create veth pair
ip link add veth0 type veth peer name vethred

# Move veth0 to namespace
ip link set veth0 netns red

# Add ip address to veth0 in namespace
ip netns exec red ip addr add 10.1.1.2/24 dev veth0

# Power on the veths
ip netns exec blue ip link set dev veth0 up
ip link set dev vethred up

# Create Linux bridge
brctl addbr br-playground
ip link set dev br-playground up

# Add interfaces
brctl addif br-playground vethblue
brctl addif br-playground vethred


