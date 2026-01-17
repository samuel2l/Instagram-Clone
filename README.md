📸 Instagram Clone

A full-featured Instagram-like social media application built with Flutter and Firebase, designed to replicate and extend core social media experiences such as real-time communication, content creation, and immersive media sharing.

This project focuses on real-time interaction, rich media, and scalability, integrating modern tools like Agora for live communication and Firebase for backend services.

⸻

🚀 Features Overview

🧑‍🤝‍🧑 Authentication & Profiles
	•	User authentication (Email / Social login)
	•	User profiles with avatar, bio, followers & following
	•	Real-time profile updates

⸻

🖼️ Posts
	•	Create image & video posts
	•	Like and unlike posts in real time
	•	Comment system (supports text, emojis, GIFs, and stickers)
	•	Realtime post updates using Firestore streams

⸻

🎞️ Reels
	•	Vertical scrolling reels (Instagram/TikTok-style)
	•	Smooth video playback
	•	Reel posting support
	•	Like system for reels
	•	Optimized video loading and caching

⸻

🌈 Stories
	•	Post image or video stories
	•	Story editor with:
	•	Scaling
	•	Positioning
	•	Resizing
	•	Rotation
	•	Stickers, GIFs, emojis, and text overlays
	•	Stories preserve exact visual state (scale, size, position) when viewed by other users
	•	Seen/unseen story tracking
	•	Automatic story expiration (24 hours)

⸻

💬 Realtime Messaging
	•	One-to-one chat
	•	Group chats
	•	Realtime message delivery
	•	Read receipts
	•	Emoji support
	•	GIFs & sticker messages
	•	Media sharing

⸻

📞 Voice & Video Calling (Agora)
	•	One-to-one voice calls
	•	One-to-one video calls
	•	Group voice calls
	•	Group video calls
	•	Low-latency real-time communication powered by Agora SDK

⸻

🔴 Live Streaming
	•	Start live streams
	•	View live streams in real time
	•	Real-time interaction during streams
	•	Designed for scalability

⸻

🧱 Tech Stack

Frontend
	•	Flutter (Dart)
	•	Riverpod (State Management)
	•	Cached Video Player
	•	Custom UI animations & gestures

Backend & Services
	•	Firebase Authentication
	•	Cloud Firestore (Realtime Database)
	•	Firebase Storage (Media uploads)
	•	Firebase Cloud Functions (optional / future use)
	•	Agora SDK (Voice, Video & Group Calls)

⸻

🗂️ Project Structure (Simplified)

lib/
├── auth/
├── posts/
├── reels/
├── stories/
├── chat/
├── calls/
├── livestream/
├── models/
├── repositories/
├── widgets/
└── main.dart


⸻

🔄 Realtime Architecture
	•	Firestore streams power:
	•	Chats
	•	Likes
	•	Story seen status
	•	Online presence
	•	Media state (story transformations) is saved as structured metadata
	•	UI reconstructs stories exactly as authored

⸻

🧠 Story Rendering Logic

When a user posts a story:
	•	All transformations (scale, position, rotation, size)
	•	Stickers, GIFs, emojis, and text metadata

Are stored in Firestore as structured data.

When another user views the story:
	•	The app replays the story using the stored metadata
	•	Resulting in pixel-accurate story rendering, identical to the creator’s version

⸻

🔐 Security
	•	Firestore security rules to protect user data
	•	Media access controlled via Firebase Storage rules
	•	Agora tokens generated securely

⸻

📦 Installation
	1.	Clone the repository

git clone https://github.com/your-org/instagram-clone.git

	2.	Install dependencies

flutter pub get

	3.	Configure Firebase

	•	Add google-services.json / GoogleService-Info.plist
	•	Enable Auth, Firestore, Storage

	4.	Configure Agora

	•	Add your Agora App ID
	•	Set up token generation

	5.	Run the app

flutter run


⸻

🧪 Status
	•	Actively developed
	•	Modular and scalable architecture
	•	Designed for real-world production use

⸻

📌 Future Enhancements
	•	Content moderation tools
	•	Notifications (FCM)
	•	Advanced analytics
	•	Monetization features

⸻

👨‍💻 Author

Built as a full-stack social media project demonstrating advanced mobile, real-time, and multimedia engineering concepts.

⸻

⭐ Acknowledgements
	•	Flutter Team
	•	Firebase
	•	Agora
	•	Open-source community