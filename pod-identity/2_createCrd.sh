AKS_CLUSTER=$1
AKS_RG=$2
IDENTITY_NAME=$3

if [ "$#" -ne 3 ] ;
then
  echo "Usage: $0 AKS_CLUSTER AKS_RG IDENTITY_NAME"
  echo ""
  echo "AKS Clusters:"
  az aks list -o table
  echo "------------------------------"
  echo "Managed IDs:"
  az identity list --query [].name -o tsv
  exit 1
fi

RESOURCE_GROUP=$(az aks show -n $AKS_CLUSTER -g $AKS_RG --query nodeResourceGroup -o tsv)
SUBSCRIPTION_ID=$(az account show --query id -o tsv)

# Creating Resource ID
#az identity create -g $RESOURCE_GROUP -n $IDENTITY_NAME --subscription $SUBSCRIPTION_ID
IDENTITY_CLIENT_ID="$(az identity show -g $RESOURCE_GROUP -n $IDENTITY_NAME --subscription $SUBSCRIPTION_ID --query clientId -otsv)"
IDENTITY_RESOURCE_ID="$(az identity show -g $RESOURCE_GROUP -n $IDENTITY_NAME --subscription $SUBSCRIPTION_ID --query id -otsv)"

IDENTITY_ASSIGNMENT_ID="$(az role assignment create --role Reader --assignee $IDENTITY_CLIENT_ID --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP --query id -otsv)"


cat <<EOF | kubectl apply -f -
apiVersion: "aadpodidentity.k8s.io/v1"
kind: AzureIdentity
metadata:
  name: $IDENTITY_NAME
spec:
  type: 0
  resourceID: $IDENTITY_RESOURCE_ID
  clientID: $IDENTITY_CLIENT_ID
EOF


cat <<EOF | kubectl apply -f -
apiVersion: "aadpodidentity.k8s.io/v1"
kind: AzureIdentityBinding
metadata:
  name: $IDENTITY_NAME-binding
spec:
  azureIdentity: $IDENTITY_NAME
  selector: $IDENTITY_NAME
EOF
