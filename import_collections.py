import firebase_admin
from firebase_admin import credentials, firestore
import json
import os

SERVICE_ACCOUNT_KEY_PATH = 'o2-clinic-a5631-firebase-adminsdk-fbsvc-ff6c5bef4f.json'
INPUT_FILE_NAME = 'doctors_trilingual_ar_en_he.json'

def main():
    if not os.path.exists(SERVICE_ACCOUNT_KEY_PATH):
        print(f"❌ Error: '{SERVICE_ACCOUNT_KEY_PATH}' not found!")
        return
        
    if not os.path.exists(INPUT_FILE_NAME):
        print(f"❌ Error: '{INPUT_FILE_NAME}' not found!")
        return

    print("Initializing Firebase...")
    cred = credentials.Certificate(SERVICE_ACCOUNT_KEY_PATH)
    
    if not firebase_admin._apps:
        firebase_admin.initialize_app(cred)
        
    db = firestore.client()

    print(f"Reading data from {INPUT_FILE_NAME}...")
    with open(INPUT_FILE_NAME, 'r', encoding='utf-8') as f:
        data = json.load(f)

    for collection_name, docs_list in data.items():
        if not isinstance(docs_list, list):
            continue
            
        print(f"⏳ Uploading {len(docs_list)} documents to collection '{collection_name}'...")
        batch = db.batch()
        count = 0
        total_uploaded = 0
        
        for doc_data in docs_list:
            # Determine document ID (prefer _id, then id)
            doc_id = doc_data.get('_id') or doc_data.get('id')
            
            if doc_id:
                doc_ref = db.collection(collection_name).document(str(doc_id))
            else:
                doc_ref = db.collection(collection_name).document()
                
            # It's usually good to keep _id and id in the document itself as well, so we don't delete them.
            batch.set(doc_ref, doc_data)
            count += 1
            total_uploaded += 1
            
            # Firestore batch limit is 500, we commit every 400
            if count == 400:
                batch.commit()
                batch = db.batch()
                count = 0
                
        if count > 0:
            batch.commit()
            
        print(f"✅ Successfully uploaded {total_uploaded} documents to '{collection_name}'.")

if __name__ == "__main__":
    main()
