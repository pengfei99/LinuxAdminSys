# Introduction of k8s concepts



## Pod (Kubernetes Concept)

`A pod is the smallest deployable unit in Kubernetes`. It represents **a group of one or more containers** that are 
scheduled and managed together.

Pod Characteristics:
 - **Shared Environment**: Containers within a pod share the same network namespace 
                          (they can communicate with each other using localhost) and storage volumes.
  - **Single IP Address**: A pod gets a single IP address, and all containers within that pod share this IP.
  - **Multiple Containers**: A pod can have multiple containers, usually working together as a single unit. 
                        For example, A main container (e.g., an NGINX web server) responsible for serving web content.
                        A sidecar container (e.g., a logging agent like Fluentd) to handle logging.
  - **Lifecycle Management**: Kubernetes handles the lifecycle of the pod, ensuring that the desired number of 
            replicas are running, restarting containers if needed, and ensuring the pod matches its defined state.
   - **High-Level Abstraction**: A pod abstracts away container specifics, letting Kubernetes manage the 
                          complexity of container scheduling, scaling, networking, and storage.
## Pod Sandbox
A pod sandbox sets up the environment for the containers, including network, storage, and DNS settings. Each pod is 
associated with one sandbox. All containers within the same pod share the same sandbox, meaning 
they share the same network namespace and IP address.

The sandbox also isolates the resources that belong to a pod from others.

### Sandbox status



## Container (containerd Concept):

A **container is a runtime instance of a containerized application** (such as an individual Docker container). 
It is a `single, isolated process` on the system with its own filesystem, networking, and process tree.

Container Characteristics:
 - **Single Process Isolation**: Containers are isolated environments, running a single application process. 
             Each container has its own filesystem, but by default, it is isolated from other containers.
  - **Managed by containerd**: In Kubernetes, containerd is responsible for creating, starting, stopping, 
        and managing containers on each node. Each pod consists of one or more containers managed by containerd.
  - **Networking**: A container has its own network namespace (unless it is part of a pod where containers 
                     share the same network).
  - **Single Unit**: A container is usually thought of as a single unit of an application, typically mapped to 
           one image (e.g., an NGINX server running in a container).

