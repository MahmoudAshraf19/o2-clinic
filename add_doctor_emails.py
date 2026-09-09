import firebase_admin
from firebase_admin import credentials, firestore
import os

SERVICE_ACCOUNT_KEY_PATH = 'o2-clinic-a5631-firebase-adminsdk-fbsvc-ff6c5bef4f.json'

def main():
    if not os.path.exists(SERVICE_ACCOUNT_KEY_PATH):
        print(f"❌ Error: '{SERVICE_ACCOUNT_KEY_PATH}' not found!")
        return

    print("Initializing Firebase...")
    cred = credentials.Certificate(SERVICE_ACCOUNT_KEY_PATH)
    
    if not firebase_admin._apps:
        firebase_admin.initialize_app(cred)
        
    db = firestore.client()
    
    doctors_ref = db.collection('Doctors')
    docs = doctors_ref.stream()
    
    batch = db.batch()
    count = 0
    total_updated = 0
    
    for idx, doc in enumerate(docs, start=1):
        email = f"doctor{idx}@gmail.com"
        doc_ref = doctors_ref.document(doc.id)
        
        batch.update(doc_ref, {'email': email})
        count += 1
        total_updated += 1
        
        print(f"Assigning {email} to doctor ID: {doc.id}")
        
        if count == 400:
            batch.commit()
            batch = db.batch()
            count = 0
            
    if count > 0:
        batch.commit()
        
    print(f"✅ Successfully updated {total_updated} doctor documents with emails.")

if __name__ == "__main__":
    main()
