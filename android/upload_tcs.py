import firebase_admin
from firebase_admin import credentials, firestore

# 1. Initialize Firebase
cred = credentials.Certificate("key.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

# 2. TCS PREMIUM DATA (Aptitude + Coding + HR)
tcs_data = {
    "aptitude": [
        {
            "question": "A shopkeeper marks an item 40% above cost price and gives 10% discount. Find overall profit%.",
            "options": ["20%", "26%", "30%", "36%"],
            "correctAnswer": "26%",
            "explanation": "Let CP=100. Marked Price=140. Selling Price = 140 - (10% of 140) = 140 - 14 = 126. Profit = 126 - 100 = 26%.",
            "shortcut": "Effective % = a + b + (ab/100) => 40 - 10 + (40*-10)/100 = 30 - 4 = 26%.",
            "category": "Quantitative Aptitude",
            "company": "TCS",
            "isPremium": True,
            "planId": "starter_199",
            "topic": "Profit and Loss"
        },
        {
            "question": "A and B together can complete a job in 12 days. B alone takes 20 days. In how many days can A alone complete the job?",
            "options": ["25 days", "30 days", "35 days", "40 days"],
            "correctAnswer": "30 days",
            "explanation": "Work = 1. A+B=1/12, B=1/20. A = 1/12 - 1/20 = 2/60 = 1/30.",
            "shortcut": "LCM of 12,20 is 60. A+B=5 units, B=3 units. A=2 units. Time = 60/2 = 30 days.",
            "category": "Quantitative Aptitude",
            "company": "TCS",
            "isPremium": True,
            "planId": "starter_199",
            "topic": "Time and Work"
        }
        # Bhai yahan baki 28 questions ka logic bhi same format mein aayega
    ],
    "coding": [
        {
            "title": "Minimum Platform Problem",
            "difficulty": "Hard",
            "company": "TCS Digital",
            "isPremium": True,
            "planId": "starter_199",
            "description": "Given arrival and departure times of all trains, find the minimum number of platforms required.",
            "solution_java": "public int findPlatform(int arr[], int dep[], int n) { Arrays.sort(arr); Arrays.sort(dep); ... }",
            "approach": "Sort both arrays. Use two pointers to count overlapping trains at any point.",
            "category": "Greedy Algorithm"
        }
    ],
    "interview": [
        {
            "question": "Tell me about a challenge you faced?",
            "isPremium": True,
            "planId": "starter_199",
            "company": "TCS",
            "category": "HR",
            "model_answer": "Use STAR Method: Describe a situation where a project failed, the action you took (e.g., debugging for 5 hours), and the positive result.",
            "tip": "Don't blame others. Focus on your problem-solving mindset."
        }
    ]
}

def start_upload():
    print("⏳ Starting TCS Premium Data Upload...")
    
    # Upload Aptitude
    for q in tcs_data["aptitude"]:
        db.collection("aptitude_questions").add(q)
        
    # Upload Coding
    for c in tcs_data["coding"]:
        db.collection("dsa_questions").add(c)
        
    # Upload HR Questions
    for i in tcs_data["interview"]:
        db.collection("interview_experiences").add(i)

    print("✅ Done! TCS content is now LIVE in your Firestore.")

if __name__ == "__main__":
    start_upload()