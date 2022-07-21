from flask import Flask, jsonify, request
# from helper import CreateUserTable, AddUser, GetUser

app = Flask(__name__)


@app.route('/')
def index():
    # CreateUserTable()
    return 'Hello world'


# @app.route('/user', methods=['POST'])
# def addUser():

#     data = request.get_json()

#     response = AddUser(data['id'], data['username'], data['email'])

#     if (response['ResponseMetadata']['HTTPStatusCode'] == 200):
#         return {
#             'msg' : 'Added user successfully',
#         }

#     return {
#             'msg' : 'Error',
#             'response' : response
#     }

# @app.route('/user/<int:id>', methods=['GET'])
# def getUser(id):
#     response = GetUser(id)

#     if (response['ResponseMetadata']['HTTPStatusCode'] == 200): 
        
#         if ('Item' in response):
#             return { 'Item': response['Item'] }

#         return { 'msg' : 'Item not found!' }

#     return {
#         'msg': 'Error',
#         'response': response
#     }

# if __name__ == "__main__":
#    app.run(host='0.0.0.0', port=5000)