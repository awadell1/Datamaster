# ConnectGoogleDrive.py
from oauth2client.client import OAuth2WebServerFlow
from oauth2client import tools
from oauth2client.contrib.keyring_storage import Storage
from apiclient.discovery import build
import httplib2

def getAuthToken(client_id, client_secret):
    # Check if stored credentials are valid
    storage = Storage('Datamaster', 'user1')
    credential = storage.get()

    # Check if credential are still valid
    if (credential is None or credential.invalid):
        # Credentials expired -> Get new one

        # Create Flow object to handle OAuth 2.0
        flow = OAuth2WebServerFlow(client_id=client_id,
                                   client_secret=client_secret,
                                   scope='https://www.googleapis.com/auth/drive',
                                   redirect_uri='urn:ietf:wg:oauth:2.0:oob')

        # Get and store new credential
        credential = tools.run_flow(flow, storage)
    return credential


def getFileList(client_id, client_secret):
    # Authenticate with Google Drive
    credential = getAuthToken(client_id, client_secret)
    http = credential.authorize(httplib2.Http())
    drive = build('drive', 'v3', http=http)

    pageToken = None
    file = []
    while True:
        # Grab a page of files from the server
        response = drive.files().list(q='fileExtension = \'ld\' or  fileExtension = \'ldx\'',
                                      fields='nextPageToken, files(id, name, md5Checksum, modifiedTime, webContentLink)',
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
