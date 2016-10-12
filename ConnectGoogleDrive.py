# ConnectGoogleDrive.py
from oauth2client.client import OAuth2WebServerFlow
from oauth2client import tools
from oauth2client.contrib.keyring_storage import Storage
from apiclient.discovery import build
import httplib2
import configparser


def getAuthToken():
    # Check if stored credentials are valid
    storage = Storage('Datamaster', 'user1')
    credential = storage.get()

    # Check if credential are still valid
    if (credential is None or credential.invalid):
        # Credentials expired -> Get new one

        # Get the Client id and secret from the config file
        config = configparser.RawConfigParser()
        config.read('config.ini')
        client_id = config.get('GoogleDriveLogin', 'client_id')
        client_secret = config.get('GoogleDriveLogin', 'client_secret')

        # Create Flow object to handle OAuth 2.0
        flow = OAuth2WebServerFlow(client_id=client_id,
                                   client_secret=client_secret,
                                   scope='https://www.googleapis.com/auth/drive',
                                   redirect_uri='urn:ietf:wg:oauth:2.0:oob')

        # Get and store new credential
        credential = tools.run_flow(flow, storage)
    return credential


def getFileList():
    # Authenticate with Google Drive
    credential = getAuthToken()
    http = credential.authorize(httplib2.Http())
    drive = build('drive', 'v3', http=http)

    pageToken = None
    file = []
    while True:
        # Grab a page of files from the server
        response = drive.files().list(q='fileExtension = \'ld\' or  fileExtension = \'ldx\'',
                                      fields='nextPageToken, files(id, name, md5Checksum, modifiedTime)',
                                      pageSize=1000,
                                      orderBy='modifiedTime',
                                      pageToken=pageToken).execute()

        # Get the token for the next page
        pageToken = response.get('nextPageToken')

        # Append to the list of files
        file = file + response.get('files', [])

        # Break if no more pages
        if pageToken is None:
            break
    return file
