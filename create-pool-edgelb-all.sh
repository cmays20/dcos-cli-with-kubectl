clusters=$1
publicnodes=$(dcos node --json | jq --raw-output ".[] | select((.type | test(\"agent\")) and (.attributes.public_ip != null)) | .id" | wc -l | awk '{ print $1 }')
cat <<EOF > pool-edgelb-all.json
{
   "apiVersion":"V2",
   "name":"all",
   "namespace":"infra/network/dcos-edgelb/pools",
   "count":${publicnodes},
   "autoCertificate":true,
   "haproxy":{
      "stats":{
         "bindPort":9090
      },
      "frontends":[
         {
            "bindPort":443,
            "protocol":"HTTPS",
            "certificates":[
               "\$AUTOCERT"
            ],
            "linkBackend":{
               "map":[
EOF
awk -v clusters=${clusters} 'BEGIN { for (i=1; i<=clusters; i++) printf("%02d\n", i) }' | while read i; do
  cat <<EOF >> pool-edgelb-all.json
                  {
                     "hostEq":"training.prod.k8s.cluster${i}.mesos.lab",
                     "backend":"training-prod-k8s-cluster${i}-backend"
                  }
EOF
  if [ $i -ne $clusters ]; then
    printf "," >> pool-edgelb-all.json
  fi
done
cat <<EOF >> pool-edgelb-all.json
               ]
            }
         }
      ],
      "backends":[
EOF
awk -v clusters=${clusters} 'BEGIN { for (i=1; i<=clusters; i++) printf("%02d\n", i) }' | while read i; do
  cat <<EOF >> pool-edgelb-all.json
         {
            "name":"training-prod-k8s-cluster${i}-backend",
            "protocol":"HTTPS",
            "services":[
               {
                  "mesos":{
                     "frameworkName":"training/prod/k8s/cluster${i}",
                     "taskNamePattern":"kube-control-plane"
                  },
                  "endpoint":{
                     "portName":"apiserver"
                  }
               }
            ]
         }
EOF
 if [ $i -ne $clusters ]; then
   printf "," >> pool-edgelb-all.json
 fi
done
cat <<EOF >> pool-edgelb-all.json
      ]
   }
}
EOF
