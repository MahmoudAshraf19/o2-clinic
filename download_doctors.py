import firebase_admin
from firebase_admin import credentials, firestore
import json
import os
from datetime import datetime

# Initialize Firebase Admin
try:
    cred = credentials.Certificate('o2-clinic-a5631-firebase-adminsdk-fbsvc-ff6c5bef4f.json')
    if not firebase_admin._apps:
        firebase_admin.initialize_app(cred)
except Exception as e:
    print(f"Error initializing Firebase: {e}")
    print("Please make sure 'serviceAccountKey.json' exists in the same directory.")
    exit(1)

db = firestore.client()

# Helper function to serialize datetime objects
def datetime_handler(x):
    if hasattr(x, 'timestamp'):
        return x.isoformat()
    raise TypeError("Unknown type")

def download_collection(collection_name, output_file):
    print(f"Fetching data from '{collection_name}' collection...")
    
    docs = db.collection(collection_name).stream()
    
    data = []
    for doc in docs:
        doc_data = doc.to_dict()
        doc_data['document_id'] = doc.id # Add document ID for reference
        data.append(doc_data)
        
    print(f"Found {len(data)} documents in '{collection_name}'.")
    
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2, default=datetime_handler)
        
    print(f"✅ Data successfully saved to {output_file}")

if __name__ == "__main__":
    download_collection("Doctors", "doctors_collection.json")
