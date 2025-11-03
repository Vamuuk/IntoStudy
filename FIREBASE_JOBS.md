# Firebase Configuration for Into Study App

## 🔥 Firestore Security Rules

Скопируйте эти правила в Firebase Console → Firestore Database → Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(uid) {
      return isAuthenticated() && request.auth.uid == uid;
    }

    // Users collection
    match /users/{userId} {
      // Users can read their own document
      allow read: if isOwner(userId);

      // Users can create their own document
      allow create: if isOwner(userId);

      // Users can update their own document
      allow update: if isOwner(userId);

      // Users cannot delete their document
      allow delete: if false;
    }

    // Notes collection
    match /notes/{noteId} {
      // Users can read their own notes
      allow read: if isAuthenticated()
                  && request.auth.uid == resource.data.userId;

      // Users can create notes for themselves
      allow create: if isAuthenticated()
                    && request.auth.uid == request.resource.data.userId;

      // Users can update their own notes
      allow update: if isAuthenticated()
                    && request.auth.uid == resource.data.userId;

      // Users can delete their own notes
      allow delete: if isAuthenticated()
                    && request.auth.uid == resource.data.userId;
    }

    // Questions collection
    match /questions/{questionId} {
      // Users can read their own questions
      allow read: if isAuthenticated()
                  && request.auth.uid == resource.data.userId;

      // Users can create questions for themselves
      allow create: if isAuthenticated()
                    && request.auth.uid == request.resource.data.userId;

      // Users can update their own questions
      allow update: if isAuthenticated()
                    && request.auth.uid == resource.data.userId;

      // Users can delete their own questions
      allow delete: if isAuthenticated()
                    && request.auth.uid == resource.data.userId;
    }

    // Chats collection
    match /chats/{chatId} {
      // Users can read chats they are members of
      allow read: if isAuthenticated()
                  && request.auth.uid in resource.data.members;

      // Users can create chats
      allow create: if isAuthenticated()
                    && request.auth.uid in request.resource.data.members
                    && request.resource.data.chatCode is string
                    && request.resource.data.chatCode.size() == 5
                    && request.resource.data.isPublic is bool;

      // Members can update chat
      allow update: if isAuthenticated()
                    && request.auth.uid in resource.data.members;

      // Members can delete chat
      allow delete: if isAuthenticated()
                    && request.auth.uid in resource.data.members;

      // Messages subcollection
      match /messages/{messageId} {
        // Chat members can read messages
        allow read: if isAuthenticated()
                    && request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.members;

        // Chat members can create messages
        allow create: if isAuthenticated()
                      && request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.members
                      && request.auth.uid == request.resource.data.senderUid;

        // Message sender can update their message
        allow update: if isAuthenticated()
                      && request.auth.uid == resource.data.senderUid;

        // Message sender can delete their message
        allow delete: if isAuthenticated()
                      && request.auth.uid == resource.data.senderUid;
      }
    }
  }
}
```

## 📊 Firestore Indexes

### Обязательные индексы:

#### 1. Notes - сортировка по дате создания
```
Collection: notes
Fields:
  - userId (Ascending)
  - createdAt (Descending)
Query scope: Collection
```

**Команда для создания:**
```bash
firebase firestore:indexes:create \
  --collection-group=notes \
  --query-scope=COLLECTION \
  --field=userId,ASC \
  --field=createdAt,DESC
```

#### 2. Notes - поиск по subject
```
Collection: notes
Fields:
  - userId (Ascending)
  - subject (Ascending)
  - createdAt (Descending)
Query scope: Collection
```

#### 3. Questions - сортировка по дате
```
Collection: questions
Fields:
  - userId (Ascending)
  - createdAt (Descending)
Query scope: Collection
```

#### 4. Questions - поиск по subject
```
Collection: questions
Fields:
  - userId (Ascending)
  - subject (Ascending)
  - createdAt (Descending)
Query scope: Collection
```

#### 5. Chats - поиск по коду (АВТОМАТИЧЕСКИЙ)
```
НЕ ТРЕБУЕТСЯ СОЗДАВАТЬ ВРУЧНУЮ!
Firestore автоматически создаёт индекс для одиночных полей.
```

**Поиск по `chatCode` работает автоматически** - индекс создаётся Firebase при первом запросе.

#### 6. Chats - сортировка для пользователя
```
Collection: chats
Fields:
  - members (Array)
  - lastMessageTime (Descending)
Query scope: Collection
```

#### 7. Messages - сортировка в чате
```
Collection group: messages
Fields:
  - chatId (Ascending)
  - createdAt (Ascending)
Query scope: Collection group
```

## 🚀 Быстрая настройка через Firebase Console

### Шаг 1: Security Rules (ОБЯЗАТЕЛЬНО!)
1. Откройте [Firebase Console](https://console.firebase.google.com/)
2. Выберите ваш проект
3. Перейдите в **Firestore Database** → **Rules**
4. Скопируйте правила из раздела выше
5. Нажмите **Publish**

**БЕЗ ЭТОГО ШАГА ПРИЛОЖЕНИЕ НЕ БУДЕТ РАБОТАТЬ!**

### Шаг 2: Indexes (Автоматическое создание)

**Хорошие новости**: Большинство индексов создаётся автоматически!

#### Что создаётся автоматически:
- ✅ Поиск по `chatCode` - одиночное поле
- ✅ Простые сортировки

#### Что нужно создать вручную (ТОЛЬКО если увидите ошибку):

Firebase покажет ошибку с ссылкой при первом использовании сложного запроса:
```
FAILED_PRECONDITION: The query requires an index.
You can create it here: https://console.firebase.google.com/...
```

**Решение**:
1. Скопируйте ссылку из ошибки
2. Откройте в браузере
3. Нажмите **Create Index**
4. Подождите 1-2 минуты
5. Готово!

#### Нужные составные индексы (если запросите):

**Notes**:
- `userId` (Ascending) + `createdAt` (Descending)
- `userId` (Ascending) + `subject` (Ascending) + `createdAt` (Descending)

**Questions**:
- `userId` (Ascending) + `createdAt` (Descending)
- `userId` (Ascending) + `subject` (Ascending) + `createdAt` (Descending)

**Chats**:
- `members` (Array) + `lastMessageTime` (Descending)

## 📝 Структура данных

### Users Collection
```json
{
  "users/{userId}": {
    "email": "user@example.com",
    "name": "John Doe",
    "createdAt": Timestamp,
    "lastLogin": Timestamp
  }
}
```

### Notes Collection
```json
{
  "notes/{noteId}": {
    "userId": "user123",
    "title": "Introduction to Flutter",
    "description": "Brief overview",
    "subject": "Software Engineering",
    "content": "Detailed content...",
    "tags": ["flutter", "mobile"],
    "attachments": [
      {
        "name": "Official Docs",
        "url": "https://flutter.dev"
      }
    ],
    "createdAt": Timestamp,
    "updatedAt": Timestamp
  }
}
```

### Questions Collection
```json
{
  "questions/{questionId}": {
    "userId": "user123",
    "title": "How to use setState?",
    "description": "Need help with state management",
    "subject": "Software Engineering",
    "content": "Detailed question...",
    "tags": ["flutter", "state"],
    "attachments": [
      {
        "name": "Code example",
        "url": "https://gist.github.com/..."
      }
    ],
    "createdAt": Timestamp,
    "updatedAt": Timestamp
  }
}
```

### Chats Collection
```json
{
  "chats/{chatId}": {
    "name": "Web Technologies",
    "avatar": "W",
    "colorHex": "#4F46E5",
    "members": ["user1", "user2"],
    "lastMessage": "Hello everyone!",
    "lastMessageTime": Timestamp,
    "createdAt": Timestamp,
    "unreadCounts": {
      "user1": 0,
      "user2": 3
    },
    "isPublic": true,
    "chatCode": "WEB23"
  }
}
```

### Messages Subcollection
```json
{
  "chats/{chatId}/messages/{messageId}": {
    "chatId": "chat123",
    "senderUid": "user1",
    "senderName": "John Doe",
    "text": "Hello!",
    "createdAt": Timestamp,
    "readBy": {
      "user1": true,
      "user2": false
    }
  }
}
```

## ⚠️ Важные примечания

### Security Rules
- Все операции требуют аутентификации (`isAuthenticated()`)
- Пользователи могут видеть только свои данные (notes, questions)
- Чаты доступны только участникам (`members`)
- Коды чатов имеют строгую валидацию (5 символов)

### Indexes
- Создавайте индексы **ДО** первого запуска приложения
- Без индексов запросы будут падать с ошибкой `FAILED_PRECONDITION`
- Индексы можно удалить в Firebase Console → Indexes

### Performance
- Индексы ускоряют запросы, но занимают место
- Сложные запросы (3+ поля) требуют составных индексов
- Firestore автоматически предлагает создать нужные индексы

## 🔧 Troubleshooting

### Ошибка: "Missing or insufficient permissions"
**Решение**: Проверьте Security Rules в Firebase Console

### Ошибка: "FAILED_PRECONDITION: The query requires an index"
**Решение**: Создайте индекс по ссылке из ошибки или вручную

### Ошибка: "Chat code must be 5 characters"
**Решение**: Обновите Security Rules с валидацией `chatCode.size() == 5`

## 📚 Дополнительные ресурсы

- [Firebase Security Rules Docs](https://firebase.google.com/docs/firestore/security/get-started)
- [Firestore Indexes Guide](https://firebase.google.com/docs/firestore/query-data/indexing)
- [Best Practices](https://firebase.google.com/docs/firestore/best-practices)

---

**Дата создания**: 2025-11-04
**Версия**: 1.0.0
**Статус**: ✅ Ready for production
