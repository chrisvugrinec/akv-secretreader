# AKV Reader

## Intro

Just a simple app that uses Managed Pod Identities to access Azure Keyvaults secrets. 
Other services within the K8 cluster can access the secrets by accessing the local service like this:

```
curl akv-secret-service:5000/get_secret([ SECRET_NAME ])
```

You can secure the access to this service within the cluster by using pod policies.

![Image of pod ID](https://raw.githubusercontent.com/chrisvugrinec/akv-secretreader/master/images/akv-reader.png)


## How to use it

- checkout code `git clone https://github.com/chrisvugrinec/akv-secretreader.git`
- prep k8 for pod managed identities:
  
  - `cd pod-identity/`
  - Create a managed Identity with the following command: `az identity create -g [ YOUR RESOURCE GROUP ] -n [ YOUR MANAGED ID NAME ]`
  - `/0_roleBindingAKSClusterID.sh AKS_CLUSTER AKS_RG`
  - `1_deployAdPodIdentity.sh`
  - `./2_createCrd.sh AKS_CLUSTER AKS_RG IDENTITY_NAME`

- You can build and push the application into your own repo, the sourcecode is in the `app` folder

- Deploy the application to your AKS cluster

  - cd to `helm/akv-reader`
  - `cp values.yaml.example values.yaml`
  - change the values in the `values.yaml`
  - helm install akv-reader akv-reader/

