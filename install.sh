declare -A cpuinfo=( ) # create an associative array

# read line-by-line; see http://mywiki.wooledge.org/BashFAQ/001
while IFS=$'\t:' read -r k v || [[ $k ]]; do
  [[ $v ]] || continue
  cpuinfo[$k]=${v# } # trim leading space; see http://wiki.bash-hackers.org/syntax/pe
done </proc/cpuinfo

echo "Model name: ${cpuinfo['model name']%@*}"
echo "Model freq: ${cpuinfo['model name']#*@}"
echo "Actual frequency: ${cpuinfo['cpu MHz']}"
echo "Siblings: ${cpuinfo['siblings']}"
