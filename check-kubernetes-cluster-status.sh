seconds=0
OUTPUT=0
sleep 5
while [ "$OUTPUT" -ne 1 ]; do
  OUTPUT=`dcos kubernetes cluster debug plan status deploy --cluster-name=${APPNAME}/prod/k8s/cluster${CLUSTER} | head -2 | tail -1 | grep -c COMPLETE`;
  seconds=$((seconds+5))
  printf "Waiting %s seconds for kubernetes cluster ${APPNAME}/prod/k8s/cluster${CLUSTER} to come up.\n" "$seconds"
  sleep 5
done
