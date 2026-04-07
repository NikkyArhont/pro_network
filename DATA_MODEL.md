# Структура базы данных (Firebase Firestore)

Архитектура разработана для простой NoSQL базы данных, где каждая сущность — это отдельная корневая коллекция. Документы связаны между собой через `id` (references), без сложных вложенных структур. Аутентификация работает через Firebase Phone Auth.

### 1. `users`
- `id` (string, uid из Firebase Auth)
- `name` (string)
- `photoUrl` (string)
- `city` (string)
- `createdAt` (timestamp)

### 2. `contacts`
- `id` (string)
- `userId` (string)
- `contactUserId` (string)
- `category` (string: friends | family | useful)
- `isMutual` (boolean)
- `createdAt` (timestamp)

### 3. `chats`
- `id` (string)
- `participants` (array из двух userId)
- `lastMessage` (string)
- `lastMessageAt` (timestamp)

### 4. `messages`
- `id` (string)
- `chatId` (string)
- `senderId` (string)
- `type` (string: text | image)
- `content` (string)
- `createdAt` (timestamp)

### 5. `posts`
- `id` (string)
- `authorId` (string, userId или professionalProfileId)
- `authorType` (string: user | professional)
- `text` (string)
- `images` (array)
- `createdAt` (timestamp)

### 6. `comments`
- `id` (string)
- `postId` (string)
- `authorId` (string)
- `text` (string)
- `createdAt` (timestamp)

### 7. `reactions`
- `id` (string)
- `postId` (string)
- `userId` (string)
- `type` (string: like)
- `createdAt` (timestamp)

### 8. `professional_profiles`
- `id` (string)
- `ownerId` (string, userId)
- `name` (string)
- `description` (string)
- `createdAt` (timestamp)

### 9. `stories` (упрощенно)
- `id` (string)
- `authorId` (string)
- `mediaUrl` (string)
- `type` (string: image | video)
- `expiresAt` (timestamp)

### 10. `favorites`
- `id` (string)
- `userId` (string)
- `postId` (string)
- `createdAt` (timestamp)
