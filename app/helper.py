import boto3
import os
session = boto3.Session()
credentials = session.get_credentials()

credentials = credentials.get_frozen_credentials()
access_key = credentials.access_key
secret_key = credentials.secret_key


client = session.client(
    'dynamodb',
    aws_access_key_id     = access_key,
    aws_secret_access_key = secret_key,
    region_name           = os.environ['REGION_NAME'],
)

resource = session.resource(
    'dynamodb',
    aws_access_key_id     = access_key,
    aws_secret_access_key = secret_key,
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