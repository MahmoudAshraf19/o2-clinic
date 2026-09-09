import json
import firebase_admin
from firebase_admin import credentials, firestore

def main():
    try:
        # Initialize Firebase Admin SDK
        cred = credentials.Certificate('o2-clinic-a5631-firebase-adminsdk-fbsvc-ff6c5bef4f.json')
        firebase_admin.initialize_app(cred)
        
        # Get Firestore client
        db = firestore.client()
        
        # Check onboarding_slides collection
        print("Checking onboarding_slides collection...")
        slides_ref = db.collection('onboarding_slides')
        slides = slides_ref.get()
        
        slide_count = 0
        for slide in slides:
            slide_count += 1
            data = slide.to_dict()
            print(f"Slide {slide_count}: {slide.id}")
            print(f"  Title: {data.get('title', 'N/A')}")
            print(f"  Description: {data.get('description', 'N/A')}")
            print(f"  Order: {data.get('order', 'N/A')}")
            print(f"  IsActive: {data.get('isActive', 'N/A')}")
            print(f"  ImageUrl: {data.get('imageUrl', 'N/A')}")
            print("---")
        
        if slide_count == 0:
            print("No slides found in the collection!")
        else:
            print(f"Found {slide_count} slides in total.")
        
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main()
