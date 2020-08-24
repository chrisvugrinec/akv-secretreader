# pod-identity-demo

## Intro

Just a simple app that uses Managed Pod Identities to access Azure Keyvaults secrets. 
Other services within the K8 cluster can access the secrets by accessing the local service like this:

```
curl akv-secret-service:5000/get_secret([ SECRET_NAME ])
```

You can secure the access to this service within the cluster by using pod policies.

![Image of pod ID](https://raw.githubusercontent.com/chrisvugrinec/akv-secretreader/master/images/akv-reader.png)
