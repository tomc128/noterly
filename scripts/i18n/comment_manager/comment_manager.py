
# If modifying these scopes, delete the file token.json.
import json
import os

from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

# If modifying these scopes, delete the file token.json.
# spreadsheets read/write, google drive read/write for comments
SCOPES = ['https://www.googleapis.com/auth/spreadsheets', 
          'https://www.googleapis.com/auth/drive']



SPREADSHEET_ID = '1c0I6lARH-S2x8sxpA2nQ1gZZm4Q6b5OyuPjVvjuvF94' # Noterly Internationalisation spreadsheet
# SPREADSHEET_RANGE = 'Translations!A1:Z500'

SPREADSHEET_RANGE = 'Translations!I6:I500'




def setup_credentials():
    creds = None
    # The file token.json stores the user's access and refresh tokens, and is
    # created automatically when the authorization flow completes for the first
    # time.
    if os.path.exists('token.json'):
        creds = Credentials.from_authorized_user_file('token.json', SCOPES)

    # If there are no (valid) credentials available, let the user log in.
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(
                'credentials.json', SCOPES)
            creds = flow.run_local_server(port=0)

        # Save the credentials for the next run
        with open('token.json', 'w') as token:
            token.write(creds.to_json())


    return creds



def build_services(creds) -> tuple:
    try:
        sheets = build('sheets', 'v4', credentials=creds)
        drive = build('drive', 'v3', credentials=creds)

        return sheets, drive
    except Exception as e:
        print(e)
        return None, None
    


def get_comments(drive) -> dict | None:
    # Call the Drive v3 API to get comments for the file
    try:
        comments = drive.comments().list(fileId=SPREADSHEET_ID, fields='comments').execute()
        return comments
    except HttpError as e:
        print(e)
        return None

    

creds = setup_credentials()
sheets, drive = build_services(creds)


comments = get_comments(drive)

if not comments:
    print('No comments found.')
    exit()

for comment in comments.get('comments', []):
    print(f"{comment['content']} - {(comment['author']['displayName'])} @ {(comment.get('anchor'))}")


print(comments.get('comments', [])[0])
