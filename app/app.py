from flask import Flask, jsonify, request
import dynamo 

app = Flask(__name__)


@app.route('/')
def index():
    dynamo.CreateUserTable()
    return 'Testing'


@app.route('/user', methods=['POST'])
def addUser():

    data = request.get_json()

    response = dynamo.AddUser(data['id'], data['username'], data['email'])

    if (response['ResponseMetadata']['HTTPStatusCode'] == 200):
        return {
            'msg' : 'Added user successfully',
        }

    return {
            'msg' : 'Error',
            'response' : response
    }

@app.route('/user/<int:id>', methods=['GET'])
def getUser(id):
    response = dynamo.GetUser(id)

    if (response['ResponseMetadata']['HTTPStatusCode'] == 200): 
        
        if ('Item' in response):
            return { 'Item': response['Item'] }

        return { 'msg' : 'Item not found!' }

    return {
        'msg': 'Error',
        'response': response
    }