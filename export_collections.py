import firebase_admin
from firebase_admin import credentials, firestore
import json
import os
from datetime import datetime

# ==========================================
# Firebase Firestore Export Script
# ==========================================
# 1. Install required package:
#    pip install firebase-admin
# 
# 2. Get your Service Account Key:
#    - Go to Firebase Console -> Project Settings -> Service Accounts
#    - Click "Generate new private key"
#    - Save the downloaded file as "serviceAccountKey.json" in the same folder as this script.
# ==========================================

SERVICE_ACCOUNT_KEY_PATH = 'o2-clinic-a5631-firebase-adminsdk-fbsvc-ff6c5bef4f.json'
OUTPUT_FILE_NAME = 'exported_collections.json'
COLLECTIONS_TO_EXPORT = ['specialized', 'Doctors']

def default_converter(o):
    """Handles datetime objects when converting to JSON"""
    if isinstance(o, datetime):
        return o.isoformat()
    # Fallback for other non-serializable objects (like DocumentReference)
    return str(o)

def main():
    if not os.path.exists(SERVICE_ACCOUNT_KEY_PATH):
        print(f"❌ Error: '{SERVICE_ACCOUNT_KEY_PATH}' not found!")
        print("Please download your Firebase service account key from the Firebase Console and place it in this directory.")
        return

    print("Initializing Firebase...")
    cred = credentials.Certificate(SERVICE_ACCOUNT_KEY_PATH)
    firebase_admin.initialize_app(cred)
    db = firestore.client()

    export_data = {}

    for collection_name in COLLECTIONS_TO_EXPORT:
        print(f"⏳ Exporting '{collection_name}'...")
        docs = db.collection(collection_name).stream()
        
        collection_list = []
        for doc in docs:
            doc_dict = doc.to_dict()
            doc_dict['_id'] = doc.id # Add document ID
            collection_list.append(doc_dict)
            
        export_data[collection_name] = collection_list
        print(f"✅ Exported {len(collection_list)} documents from '{collection_name}'.")

    # Save data to JSON
    print(f"💾 Saving data to {OUTPUT_FILE_NAME}...")
    with open(OUTPUT_FILE_NAME, 'w', encoding='utf-8') as f:
        json.dump(export_data, f, ensure_ascii=False, indent=4, default=default_converter)
        
    print("🎉 Export completed successfully!")

if __name__ == "__main__":
    main()
