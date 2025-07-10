# Debug application in a cluster

## Identify bug level

One application needs three levels to work:
- pod level
- service level
- ingress level

We need to identify which level has problems

## Debug a pod level problem

### 1. Check Pod Status

Each Pod has a status, we start by identifying its current status:

```shell
# general form
kubectl get pod <pod-name> -n <name-space> -o wide

# an example
kubectl get pod ingress-nginx-controller-qt489 -n ingress-nginx -o wide

# output example
NAME                                  READY   STATUS    RESTARTS   AGE   IP               NODE         NOMINATED NODE   READINESS GATES
argocd-repo-server-57b9648b6c-g7dmx   1/1     Running   0          21m   192.168.14.203   onyxia-w01   <none>           <none>
```
Look at `STATUS, RESTARTS, and NODE`.

Typical statuses:

- Pending: can't be scheduled
- ContainerCreating: image pull, volume, or init issues
- CrashLoopBackOff: container repeatedly fails
- Error: container exited non-zero

### 2. Inspect Events

```shell
kubectl describe pod ingress-nginx-controller-qt489 -n ingress-nginx
```

Look at the "Events" section at the bottom, check if there are:
- Volume mount errors
- Image pull errors
- Init container failures
- Admission webhook issues
- Node scheduling constraints

### 3. Check Container Logs
If the pod reached running state briefly:
```shell
kubectl logs ingress-nginx-controller-qt489 -n ingress-nginx
```
If the pod has multiple containers (e.g., controller + admission):

```shell
kubectl logs ingress-nginx-controller-qt489 -n ingress-nginx -c <container-name>

```
If restarting:

```shell
kubectl logs --previous ingress-nginx-controller-qt489 -n ingress-nginx
```

### 4. Check Events on Node (if stuck in Pending)

```shell
kubectl get events --sort-by='.metadata.creationTimestamp' -A | grep ingress-nginx
```
You might see:

Insufficient CPU/memory

Taints not tolerated

Node selector mismatch

🔹 5. Verify Volume Mounts
If you mounted the CA:

Ensure secret exists:

bash
Copy
Edit
kubectl get secret root-ca -n ingress-nginx -o yaml
Ensure volume and volumeMount path is correct.

Check file permissions (readOnly: true + non-root user?).