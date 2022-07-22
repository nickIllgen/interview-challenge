import boto3
import os

sts_client = boto3.client('sts')

# Call the assume_role method of the STSConnection object and pass the role
# ARN and a role session name.
assumed_role_object=sts_client.assume_role(
    RoleArn="arn:aws:iam::809031430406:role/ibm-rest-eks-42WN3Awe2022072017423942420000000e",
    RoleSessionName="AssumeRoleSession1"
)
credentials=assumed_role_object['Credentials']
client = boto3.client(
    'dynamodb',
    aws_access_key_id=credentials['AccessKeyId'],
    aws_secret_access_key=credentials['SecretAccessKey'],
    aws_session_token=credentials['SessionToken'],
    region_name           = os.environ['REGION_NAME'],
)

resource = boto3.resource(
    'dynamodb',
    aws_access_key_id=credentials['AccessKeyId'],
    aws_secret_access_key=credentials['SecretAccessKey'],
    aws_session_token=credentials['SessionToken'],
    region_name           = os.environ['REGION_NAME'],
)

def CreateUserTable():
    client.create_table(
        AttributeDefinitions = [
            
            {
                'AttributeName' : 'id',
                'AttributeType' : 'N'
            }
        ],
        TableName = 'User',
        KeySchema = [
            {
                'AttributeName' : 'id',
                'KeyType'       : 'HASH'
            }
        ],
        BillingMode='PAY_PER_REQUEST'


    )

UserTable = resource.Table('User')
def AddUser(id, username, email):

    response = UserTable.put_item(
        Item = {
            'id'         : id,
            'username'   : username,
            'email'      : email,
        }

    )
    return response

def GetUser(id):
    response = UserTable.get_item(
        Key = {
            'id'    : id
        },
        AttributesToGet = [
            'username', 'email'
        ]
    )
    return response