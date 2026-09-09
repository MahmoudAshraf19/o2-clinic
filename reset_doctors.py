import firebase_admin
from firebase_admin import credentials, firestore
import os

SERVICE_ACCOUNT_KEY_PATH = "o2-clinic-a5631-firebase-adminsdk-fbsvc-ff6c5bef4f.json"
COLLECTION_NAME = "Doctors"

def main():
    if not os.path.exists(SERVICE_ACCOUNT_KEY_PATH):
        print(f"Error: Could not find the service account key at '{SERVICE_ACCOUNT_KEY_PATH}'.")
        return

    print("Initializing Firebase...")
    cred = credentials.Certificate(SERVICE_ACCOUNT_KEY_PATH)
    try:
        firebase_admin.initialize_app(cred)
    except ValueError:
        pass # Already initialized
    
    db = firestore.client()

    print(f"Fetching documents from '{COLLECTION_NAME}' collection...")
    docs = db.collection(COLLECTION_NAME).stream()
    
    batch = db.batch()
    count = 0
    
    for doc in docs:
        doc_ref = db.collection(COLLECTION_NAME).document(doc.id)
        
        if doc.id in ['doctor_7', 'doctor_10']:
            batch.update(doc_ref, {
                'the_top': True,
                'is_top_rate_enable': True
            })
        else:
            batch.update(doc_ref, {
                'the_top': False,
                'is_top_rate_enable': False
            })
        count += 1
        
    if count > 0:
        batch.commit()
        print(f"Successfully updated {count} doctors. isTopRated and isMostBooked are now false for all.")
    else:
        print("No doctors found in the collection.")

if __name__ == "__main__":
    main()
