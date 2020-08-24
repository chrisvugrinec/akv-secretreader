from collections import OrderedDict
from flask import Flask, request, jsonify
from flask_restplus import fields, Api, Resource
import os
from msrestazure.azure_active_directory import MSIAuthentication
from azure.mgmt.resource import ResourceManagementClient, SubscriptionClient
from azure.keyvault.secrets import SecretClient
from azure.identity import ManagedIdentityCredential

app = Flask(__name__)
api = Api(app)

output_model = api.model('Model', {
  'secret_value': fields.String
})


class SecretTest(object):
  def __init__(self, secret_name):
    self.secret_value = "hello "+secret_name

# JSON Output model
class Secret(object):
  def __init__(self, secret_name):
    self.status = 'active'
    credentials =  ManagedIdentityCredential(
      msi_res_id= os.environ.get('MSID')
    )
    secret_client = SecretClient(vault_url="https://"+os.environ.get('KEY_VAULT_NAME')+".vault.azure.net", credential=credentials)
    secret = secret_client.get_secret(secret_name)
    self.secret_value = secret.value

def get_secret(secret_name):
  credentials =  ManagedIdentityCredential(
    msi_res_id= os.environ.get('MSID')
  )
  secret_client = SecretClient(vault_url="https://"+os.environ.get('KEY_VAULT_NAME')+".vault.azure.net", credential=credentials)
  secret = secret_client.get_secret(secret_name)
  return secret.value


@api.route('/get_secret')
class AKVService(Resource):
  @api.marshal_with(output_model)
  def get(self, **kwargs):
    return Secret(request.args.get('secret_name'))

if __name__ == '__main__':
  app.run(host='0.0.0.0')
