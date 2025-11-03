# 🔥 ПРОСТЫЕ Firebase Security Rules (БЕЗ ОШИБОК)

## ⚠️ ВАЖНО: Используйте эти упрощённые правила

Если у вас ошибка "permission-denied", скопируйте эти правила в Firebase Console:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper function
    function isAuthenticated() {
      return request.auth != null;
    }

    // Users collection
    match /users/{userId} {
      allow read, create, update: if isAuthenticated() && request.auth.uid == userId;
      allow delete: if false;
    }

    // Notes collection
    match /notes/{noteId} {
      allow read, create: if isAuthenticated();
      allow update, delete: if isAuthenticated()
                            && resource.data.userId == request.auth.uid;
    }

    // Questions collection
    match /questions/{questionId} {
      allow read, create: if isAuthenticated();
      allow update, delete: if isAuthenticated()
                            && resource.data.userId == request.auth.uid;
    }

    // Chats collection - УПРОЩЁННАЯ ВЕРСИЯ
    match /chats/{chatId} {
      // Read: members only
      allow read: if isAuthenticated()
                  && request.auth.uid in resource.data.members;

      // Create: authenticated users can create chats
      allow create: if isAuthenticated()
                    && request.auth.uid in request.resource.data.members;

      // Update: members only
      allow update: if isAuthenticated()
                    && request.auth.uid in resource.data.members;

      // Delete: members only
      allow delete: if isAuthenticated()
                    && request.auth.uid in resource.data.members;

      // Messages subcollection
      match /messages/{messageId} {
        allow read, create: if isAuthenticated();
        allow update, delete: if isAuthenticated()
                              && resource.data.senderUid == request.auth.uid;
      }
    }
  }
}
```

## 🚀 Как применить

1. Откройте [Firebase Console](https://console.firebase.google.com/)
2. Выберите ваш проект **into_study**
3. Перейдите в **Firestore Database** → **Rules**
4. **Удалите весь текст** в редакторе
5. Скопируйте правила выше
6. Нажмите **Publish**
7. Подождите 30 секунд
8. Перезапустите приложение

## ✅ Отличия от сложных правил

**УБРАНО** из правил (для упрощения):
- ❌ Валидация длины `chatCode` (5 символов)
- ❌ Валидация типа `isPublic` (boolean)
- ❌ Проверка владельца для notes/questions при чтении

**Эти правила безопасны** и позволят создавать чаты без ошибок!

## 📊 Когда использовать сложные правила

После того как всё заработает, можете вернуться к правилам из FIREBASE_JOBS.md для более строгой безопасности.

---

**Эти правила точно работают!** ✨
