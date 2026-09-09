import firebase_admin
from firebase_admin import credentials, firestore
import json
import os

# ---------------------------------------------------------
# 1. Add your Firebase Admin SDK service account key path here
# You can generate this from Firebase Console -> Project Settings -> Service Accounts -> Generate new private key
# ---------------------------------------------------------
SERVICE_ACCOUNT_KEY_PATH = "o2-clinic-a5631-firebase-adminsdk-fbsvc-ff6c5bef4f.json"

# Collection name in Firestore
COLLECTION_NAME = "doctors"  # Change to "Doctors" if your collection starts with a capital letter
OUTPUT_FILE = "doctors_data.json"

def main():
    if not os.path.exists(SERVICE_ACCOUNT_KEY_PATH):
        print(f"Error: Could not find the service account key at '{SERVICE_ACCOUNT_KEY_PATH}'.")
        print("Please update SERVICE_ACCOUNT_KEY_PATH with the correct path to your json key file.")
        return

    # Initialize Firebase Admin
    print("Initializing Firebase...")
    cred = credentials.Certificate(SERVICE_ACCOUNT_KEY_PATH)
    firebase_admin.initialize_app(cred)
    
    db = firestore.client()

    print(f"Fetching all documents from '{COLLECTION_NAME}' collection...")
    docs = db.collection(COLLECTION_NAME).stream()
    
    doctors_data = []
    
    for doc in docs:
        doc_dict = doc.to_dict()
        doc_dict['id'] = doc.id  # Include the document ID
        doctors_data.append(doc_dict)
        
    print(f"Successfully fetched {len(doctors_data)} doctors.")
    
    # Save to JSON file
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(doctors_data, f, ensure_ascii=False, indent=4, default=str)
        
    print(f"Data saved to {OUTPUT_FILE}")

if __name__ == "__main__":
    main()
