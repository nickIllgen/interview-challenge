from boto3 import client, resource
import os
client = client(
    'dynamodb',
    aws_access_key_id     = os.environ['AWS_ACCESS_KEY_ID'],
    aws_secret_access_key = os.environ['AWS_SECRET_ACCESS_KEY'],
    region_name           = os.environ['REGION_NAME'],
)

resource = resource(
    'dynamodb',
    aws_access_key_id     = os.environ['AWS_ACCESS_KEY_ID'],
    aws_secret_access_key = os.environ['AWS_SECRET_ACCESS_KEY'],
    region_name           = os.environ['REGION_NAME'],
)

def createUserTable():
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
def addUser(id, username, email):

    response = UserTable.put_item(
        Item = {
            'id'         : id,
            'username'   : username,
            'email'      : email,
        }

    )
    return response

def getUser(id):
    response = UserTable.get_item(
        Key = {
            'id'    : id
        },
        AttributesToGet = [
            'username', 'email'
        ]
    )
    return response