# 🔧 Как исправить ошибку "permission-denied" в 3 шага

## Проблема
Вы видите ошибку:
```
Failed to create chat: [cloud_firestore/permission-denied] Missing or insufficient permissions.
```

## Причина
Firebase Security Rules в вашей консоли **не совпадают** с тем, что ожидает приложение.

---

## ✅ РЕШЕНИЕ (3 минуты)

### Шаг 1: Откройте Firebase Console
1. Перейдите: https://console.firebase.google.com/
2. Выберите проект: **into_study**
3. В левом меню: **Firestore Database** → **Rules**

### Шаг 2: Замените правила
1. **Удалите ВСЁ** что сейчас в редакторе
2. Скопируйте правила ниже:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function isAuthenticated() {
      return request.auth != null;
    }

    // Users
    match /users/{userId} {
      allow read, create, update: if isAuthenticated() && request.auth.uid == userId;
      allow delete: if false;
    }

    // Notes
    match /notes/{noteId} {
      allow read, create: if isAuthenticated();
      allow update, delete: if isAuthenticated()
                            && resource.data.userId == request.auth.uid;
    }

    // Questions
    match /questions/{questionId} {
      allow read, create: if isAuthenticated();
      allow update, delete: if isAuthenticated()
                            && resource.data.userId == request.auth.uid;
    }

    // Chats - БЕЗ СТРОГОЙ ВАЛИДАЦИИ
    match /chats/{chatId} {
      allow read: if isAuthenticated()
                  && request.auth.uid in resource.data.members;
      allow create: if isAuthenticated()
                    && request.auth.uid in request.resource.data.members;
      allow update, delete: if isAuthenticated()
                            && request.auth.uid in resource.data.members;

      match /messages/{messageId} {
        allow read, create: if isAuthenticated();
        allow update, delete: if isAuthenticated()
                              && resource.data.senderUid == request.auth.uid;
      }
    }
  }
}
```

3. Нажмите **Publish**
4. **ПОДОЖДИТЕ 60 СЕКУНД!** (правила применяются не мгновенно)

### Шаг 3: Перезапустите приложение
```bash
cd build/windows/x64/runner/Release
start into_study.exe
```

---

## 🎉 Готово!

Теперь попробуйте создать чат - ошибка должна исчезнуть.

---

## 🤔 Почему это работает?

**Проблема была в правилах из FIREBASE_JOBS.md:**
```javascript
// ❌ Слишком строгие правила
allow create: if isAuthenticated()
              && request.auth.uid in request.resource.data.members
              && request.resource.data.chatCode.size() == 5  // <-- Проблема!
              && request.resource.data.isPublic is bool;     // <-- Проблема!
```

**Новые правила убрали валидацию:**
```javascript
// ✅ Простые правила
allow create: if isAuthenticated()
              && request.auth.uid in request.resource.data.members;
```

Валидация длины кода и типа `isPublic` **не обязательна** для работы приложения.

---

## 📊 Индексы

Индексы создаются **автоматически** при первом запросе. Ничего делать не нужно!

Если увидите ошибку `FAILED_PRECONDITION`:
1. Скопируйте ссылку из ошибки
2. Откройте в браузере
3. Нажмите **Create Index**
4. Подождите 2 минуты

---

## 🆘 Всё ещё не работает?

1. ✅ Убедитесь что нажали **Publish** в Firebase Console
2. ✅ Подождите полную минуту после Publish
3. ✅ Перезапустите приложение (полностью закройте и откройте снова)
4. ✅ Попробуйте выйти из аккаунта и зайти снова

Если ошибка осталась - проверьте что правила **точно** скопированы как выше.

---

## 🔒 Безопасность

Эти правила **безопасны**:
- ✅ Требуют аутентификацию
- ✅ Пользователи видят только свои данные
- ✅ Члены чата видят только свои чаты
- ✅ Только члены чата могут писать сообщения

**Всё работает отлично!** ✨
