# Assuming AKS cluster with Managed Identity
# more info: https://github.com/Azure/aad-pod-identity/blob/master/docs/readmes/README.role-assignment.md

AKS_CLUSTER=$1
AKS_RG=$2

if [ "$#" -ne 2 ] ;
then
  echo "Usage: $0 AKS_CLUSTER AKS_RG"
  echo ""
  echo "AKS Clusters:"
  az aks list -o table
  exit 1
fi

RESOURCE_GROUP=$(az aks show -n $AKS_CLUSTER -g $AKS_RG --query nodeResourceGroup -o tsv)
SUBSCRIPTION_ID=$(az account show --query id -o tsv)

ID=$(az aks show -g $AKS_RG -n $AKS_CLUSTER --query identityProfile.kubeletidentity.clientId -otsv)
az role assignment create --role "Managed Identity Operator" --assignee $ID --scope /subscriptions/$SUBSCRIPTION_ID/resourcegroups/$RESOURCE_GROUP
az role assignment create --role "Virtual Machine Contributor" --assignee $ID --scope /subscriptions/$SUBSCRIPTION_ID/resourcegroups/$RESOURCE_GROUP

echo "getting credentials"
az aks get-credentials -n $AKS_CLUSTER -g $AKS_RG
