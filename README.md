# Rezerwacja Noclegów – API (NestJS + MongoDB)

Aplikacja backendowa do rezerwacji noclegów, stworzona w oparciu o [NestJS](https://nestjs.com/).  
Obsługuje rejestrację użytkowników, logowanie, zarządzanie pokojami, system rezerwacji oraz polubień.  
Autoryzacja oparta o **JWT**.

---

## 🚀 Funkcjonalności

- **Autentykacja użytkowników**
  - Rejestracja i logowanie
  - Sprawdzenie dostępności email / username
  - Ochrona endpointów JWT
- **Profile użytkowników**
  - Publiczne profile
  - Dostęp do własnego profilu
- **Pokoje**
  - Tworzenie, edycja, usuwanie (tylko właściciel)
  - Lista wszystkich pokoi
  - Szczegóły pokoju
- **Rezerwacje**
  - Rezerwacja pokoju
  - Zabezpieczenia (brak podwójnych rezerwacji, właściciel nie rezerwuje własnych pokoi)
- **Polubienia**
  - Like / Dislike pokoju
  - Brak wielokrotnego głosowania

---

## 🏗 Architektura

- **NestJS – modułowa architektura**
  - `Auth`, `Users`, `Rooms`
- **Warstwy**
  - Kontrolery (obsługa HTTP)
  - Serwisy (logika biznesowa)
  - Schematy Mongoose (MongoDB)
  - DTO (walidacja danych)
  - Guards (autoryzacja)
  - Filters (obsługa błędów)
- **Baza danych**: MongoDB
- **Autentykacja**: JWT + Passport.js

---

## ⚙️ Wymagania

- Node.js v20+
- npm
- MongoDB (lokalnie lub Docker)
- Docker + Docker Compose (opcjonalnie)

---

## ▶️ Uruchomienie

### 1. Z Docker Compose
```bash
git clone https://github.com/trak2026z/rezerwacja-noclegow-nest.git
cd rezerwacja-noclegow-nest
docker-compose up
```
Aplikacja: `http://localhost:3000`

### 2. Lokalnie
```bash
git clone https://github.com/trak2026z/rezerwacja-noclegow-nest.git
cd rezerwacja-noclegow-nest
npm install
```

Utwórz `.env` (patrz `.env.example`):
```env
MONGODB_URI=mongodb://localhost:27017/rezerwacja-noclegow
JWT_SECRET=your_secret
JWT_EXPIRATION=1d
```

Uruchom:
```bash
npm run start:dev
```

---

## 📡 Endpointy API

### Health
- `GET /health`

### Auth
- `POST /auth/register` – rejestracja
- `POST /auth/login` – logowanie
- `GET /auth/checkEmail/:email`
- `GET /auth/checkUsername/:username`

### Users
- `GET /users/profile` – własny profil (JWT)
- `GET /users/:username` – profil publiczny

### Rooms
- `POST /rooms` – utworzenie pokoju (JWT, właściciel)
- `GET /rooms` – lista pokoi
- `GET /rooms/:id` – szczegóły
- `PUT /rooms/:id` – edycja (JWT, właściciel)
- `DELETE /rooms/:id` – usunięcie (JWT, właściciel)
- `POST /rooms/:id/reserve` – rezerwacja (JWT, gość)
- `POST /rooms/:id/like` – polubienie
- `POST /rooms/:id/dislike` – niepolubienie

---

## 🛠 Skrypty pomocnicze

W katalogu `scripts/` znajdują się skrypty testowe (`test4.sh`, `test4add.sh`).  
Przykład:
```bash
cd scripts
chmod +x test4.sh
./test4.sh
```

---

## 📂 Struktura projektu

```
src/
 ├── app.module.ts
 ├── main.ts
 ├── auth/
 ├── users/
 ├── rooms/
 ├── config/
 └── filters/
```

---

## 🗄 Modele danych

### User
```ts
{
  _id: ObjectId,
  email: string,
  username: string,
  password: string (hashed),
  createdAt: Date,
  updatedAt: Date
}
```

### Room
```ts
{
  _id: ObjectId,
  title: string,
  body: string,
  city: string,
  startAt: Date,
  endsAt: Date,
  owner: ObjectId (ref: User),
  reserved: boolean,
  reservedBy: ObjectId (ref: User),
  likes: [ObjectId],
  dislikes: [ObjectId],
  createdAt: Date,
  updatedAt: Date
}
```

---

## ❗ Obsługa błędów

- `200 OK` – sukces
- `201 Created` – utworzono
- `400 Bad Request`
- `401 Unauthorized`
- `403 Forbidden`
- `404 Not Found`
- `409 Conflict`
- `500 Internal Server Error`

---

## 👤 Autorzy

- trak2026z – GitHub

---

## 📜 Licencja

Projekt dostępny na licencji MIT.
