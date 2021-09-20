#!/bin/bash

COLORS=(red yellow blue brown orange green violet black carnation-pink yellow-orange blue-green red-violet red-orange yellow-green blue-violet white violet-red dandelion cerulean apricot scarlet green-yellow indigo gray)
DEFAULT_BRIDGE="br"
DEFAULT_NUMBER_OF_NAMESPACES=2

bridge_type=$DEFAULT_BRIDGE
number_of_namespaces=$DEFAULT_NUMBER_OF_NAMESPACES
bridge_name="br-playground"

# Create 'env.config' and empty it if not empty
echo -n > env.config

while getopts "s:n:" arg; do
  case $arg in
    s)
      if [ $OPTARG == "br" ] || [ $OPTARG == "ovs" ]
      then  
        bridge_type=$OPTARG
      fi
      ;;
    n)
      re='^[0-9]+$'
      if [[ $OPTARG =~ $re ]] && [[ $OPTARG -le 24 ]]; then
        number_of_namespaces=$OPTARG
      fi
      ;;
  esac
done

# Build config file
echo "bridge_type=$bridge_type" >> env.config
echo "bridge_name=$bridge_name" >> env.config
echo "number_of_namespaces=$number_of_namespaces" >> env.config
echo -n "namespaces=\"" >> env.config

for i in $(seq 1 $number_of_namespaces)
do
  echo -n "${COLORS[$i]}-ns " >> env.config 
done

echo "\"" >> env.config


. env.config

echo "The following namespaces will be created: $namespaces"
namespaces=($namespaces)

if [ $bridge_type == 'br' ]
then
  # Create Linux bridge
  echo [$bridge_name] Creating linux bridge
  brctl addbr $bridge_name
  ip link set dev $bridge_name up
fi

for ns in "${namespaces[@]}"
do
  echo $ns
done

i=1
for ns in "${namespaces[@]}"
do

  interface_name="veth-$ns"
  # Create namespace
  echo [$ns] Creating namespace
  ip netns add $ns

  # Set up loopback interface
  echo [$ns] Setting up loopback interface
  ip netns exec $ns ip link set dev lo up

  # Create veth pair
  echo [$ns] Create veth pair veth0:$interface_name
  ip link add veth0 type veth peer name $interface_name

  # Move veth0 to namespace
  echo [$ns] Moving veth0 to $ns
  ip link set veth0 netns $ns

  # Add ip address to veth0 in namespace
  echo "[$ns] Adding IP address 10.1.1.$i/24 to veth0 in $ns"
  #ip netns exec $ns ip addr add 10.1.1.1/24 dev veth0
  ip netns exec $ns ip addr add 10.1.1.$i/24 dev veth0
  i=$(( $i + 1 ))

  # Power on the veths
  ip netns exec $ns ip link set dev veth0 up
  ip link set dev $interface_name up

  # Add interfaces to bridge
  echo "[$ns] Adding interface $interface_name to bridge "
  brctl addif $bridge_name $interface_name
done