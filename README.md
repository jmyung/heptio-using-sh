# How to standup pacific.cluster.cnct.io (Cluster Specification Repository)

This is necessary instructions and code necessary to recreate `pacific` for the first time must be checked in there

## **Instruction**

> ### Setup In AWS

### **STEP 1 - Bring up Cluster with Heptio's Cloudformation template**

#### 1-1. Set the environment valuable
- Required:
  - **CLUSTER_ID** This is the name of the cluster, eg "MyCluster".
  - **AWS_ACCESS_KEY_ID** The aws access key id to create the cluster with.
  - **AWS_SECRET_ACCESS_KEY** The aws secret associated with the above key.
  - **AWS_DEFAULT_REGION** The aws region in which to build this cluster.
  - **AVAILABILITY_ZONE** A single availability zone the the default region.

- Optional:
  - **BASTION_INSTANCE_TYPE** The aws bastion instance type. Default: t2.micro
  - **INSTANCE_TYPE** The aws instance type. Default: m4.large
  - **DISK_SIZE_GB** The instance disk size in gigabytes. Default: 100
  - **SSH_LOCATION** The CIDR allowed to ssh in to this cluster. Default: 0.0.0.0/0
  - **K8S_NODE_CAPACITY** The number of worker nodes in this cluster. Default: 1
  
  ```
  [~]$ export CLUSTER_ID=jason-heptio
  [~]$ export AWS_ACCESS_KEY_ID=
  [~]$ export AWS_SECRET_ACCESS_KEY=
  [~]$ export AWS_DEFAULT_REGION=us-west-2
  [~]$ export AVAILABILITY_ZONE=us-west-2a
  ```

#### 1-2. Execute script to bring up a cluster
- execute script
```
$ ./make_cluster_with_heptio_with_new_vpc.sh
```

- keypair.pem will be generated in your local

### **STEP 2 - How to get a info after Creation completed**
#### 2-1. Get kubeconfig
```
$ aws cloudformation describe-stacks --stack-name $CLUSTER_ID --query "Stacks[*]" | jq '.[0].Outputs[] | select(.OutputKey=="GetKubeConfigCommand") | .OutputValue'
"SSH_KEY=\"path/to/jason-test-heptio5Key.pem\"; scp -i $SSH_KEY -o ProxyCommand=\"ssh -i \\\"${SSH_KEY}\\\" ubuntu@54.203.22.61 nc %h %p\" ubuntu@10.0.9.146:~/kubeconfig ./kubeconfig"
[~/dev/heptio-using-sh]$ SSH_KEY="jason-make-clusterKey.pem"
[~/dev/heptio-using-sh]$ scp -i ./jason-make-clusterKey.pem -o ProxyCommand="ssh -i \"./jason-make-clusterKey.pem\" ubuntu@34.221.202.44 nc %h %p" ubuntu@10.0.20.141:~/kubeconfig ./kubeconfig
###############################################################
#       _   _            _   _         _    ___               #
#      | | | | ___ _ __ | |_(_) ___   | | _( _ ) ___          #
#      | |_| |/ _ \ '_ \| __| |/ _ \  | |/ / _ \/ __|         #
#      |  _  |  __/ |_) | |_| | (_) | |   < (_) \__ \         #
#      |_| |_|\___| .__/ \__|_|\___/  |_|\_\___/|___/         #
#                 |_|                                         #
#        ___        _      _     ____  _             _        #
#       / _ \ _   _(_) ___| | __/ ___|| |_ __ _ _ __| |_      #
#      | | | | | | | |/ __| |/ /\___ \| __/ _` | '__| __|     #
#      | |_| | |_| | | (__|   <  ___) | || (_| | |  | |_      #
#       \__\_\\__,_|_|\___|_|\_\|____/ \__\__,_|_|   \__|     #
#                                                             #
###############################################################
The authenticity of host '10.0.20.141 (<no hostip for proxy command>)' can't be established.
ECDSA key fingerprint is SHA256:IZkhbc5PhstO3yKic5DNvA6cgjbHrlm90vbjk1cwbYM.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '10.0.20.141' (ECDSA) to the list of known hosts.
kubeconfig                                                                                                                                                                    100% 5393   461.5KB/s   00:00
Killed by signal 1.
```

#### 2-2. Get node info
```
[~/dev/heptio-using-sh]$ kubectl get no --kubeconfig kubeconfig
NAME                                        STATUS    ROLES     AGE       VERSION
ip-10-0-20-141.us-west-2.compute.internal   Ready     master    10m       v1.10.3
ip-10-0-30-249.us-west-2.compute.internal   Ready     <none>    8m        v1.10.3
```

#### 2-3. Get cluster info
```
[~/dev/heptio-using-sh]$ kubectl cluster-info --kubeconfig kubeconfig
Kubernetes master is running at https://jason-mak-apiloadb-d9qq1qu0yvak-1646597243.us-west-2.elb.amazonaws.com
KubeDNS is running at https://jason-mak-apiloadb-d9qq1qu0yvak-1646597243.us-west-2.elb.amazonaws.com/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
```
