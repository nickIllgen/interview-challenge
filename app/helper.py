import boto3

session = boto3.Session(profile_name='default')
client = session.client('dynamodb')

resource = session.resource('dynamodb')

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