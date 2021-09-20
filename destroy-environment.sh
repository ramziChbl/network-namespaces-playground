#!/bin/bash

# Load config file
echo Loading config file env.config
. env.config


if [ $bridge_type == 'br' ]
then
    echo [$bridge_name] Deleting bridge, type : $bridge_type
    ip link set dev $bridge_name down
    brctl delbr $bridge_name    
fi

# Delete namespaces
namespaces=($namespaces)
for ns in "${namespaces[@]}"
do
    echo [$ns] Deleting namespace
    ip netns delete $ns
done