#!/bin/sh -eu
#Check for x86-64-v2, v3, v4 support

flags=$(cat /proc/cpuinfo | grep flags | head -n 1 | cut -d: -f2)

supports_v2='awk "/cx16/&&/lahf/&&/popcnt/&&/sse4_1/&&/sse4_2/&&/ssse3/ {found=1} END {exit !found}"'
supports_v3='awk "/avx/&&/avx2/&&/bmi1/&&/bmi2/&&/f16c/&&/fma/&&/abm/&&/movbe/&&/xsave/ {found=1} END {exit !found}"'
supports_v4='awk "/avx512f/&&/avx512bw/&&/avx512cd/&&/avx512dq/&&/avx512vl/ {found=1} END {exit !found}"'

echo "No x86-64-v2 -3 -4 support"

echo -e "\e[1A\e[K$flags" | eval $supports_v2 || exit 2 && echo -e "\e[1A\e[KYour CPU supports x86-64-v2"
echo -e "\e[1A\e[K$flags" | eval $supports_v3 || exit 3 && echo -e "\e[1A\e[KYour CPU supports x86-64-v3"
echo -e "\e[1A\e[K$flags" | eval $supports_v4 || exit 4 && echo -e "\e[1A\e[KYour CPU supports x86-64-v4"
