#!/usr/bin/env bash
set -euo pipefail

BASE_URL="http://localhost:3000"

echo "=== Health ==="
curl -s "${BASE_URL}/health" | jq .

echo "=== Swagger (head) ==="
curl -sI "${BASE_URL}/api" | head -n 5

############################################
# 1) AUTH — rejestracja i logowanie
############################################

echo
echo "=== AUTH: Rejestracja user1 (owner) ==="
curl -s -X POST "${BASE_URL}/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "owner@example.com",
    "username": "owner1",
    "password": "secret12"
  }' | jq .

echo
echo "=== AUTH: Rejestracja user2 (guest) ==="
curl -s -X POST "${BASE_URL}/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "guest@example.com",
    "username": "guest1",
    "password": "secret12"
  }' | jq .

echo
echo "=== AUTH: Logowanie user1 ==="
OWNER_LOGIN_JSON=$(curl -s -X POST "${BASE_URL}/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"username":"owner1","password":"secret12"}')

echo "$OWNER_LOGIN_JSON" | jq .
OWNER_TOKEN=$(echo "$OWNER_LOGIN_JSON" | jq -r '.token')
OWNER_ID=$(echo "$OWNER_LOGIN_JSON" | jq -r '.user._id')

echo
echo "=== AUTH: Logowanie user2 ==="
GUEST_LOGIN_JSON=$(curl -s -X POST "${BASE_URL}/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"username":"guest1","password":"secret12"}')

echo "$GUEST_LOGIN_JSON" | jq .
GUEST_TOKEN=$(echo "$GUEST_LOGIN_JSON" | jq -r '.token')
GUEST_ID=$(echo "$GUEST_LOGIN_JSON" | jq -r '.user._id')

echo "OWNER_ID=${OWNER_ID}"
echo "GUEST_ID=${GUEST_ID}"

############################################
# 2) USERS — publiczny profil
############################################

echo
echo "=== USERS: Publiczny profil owner1 ==="
curl -s "${BASE_URL}/users/owner1" | jq .

############################################
# 3) ROOMS — CRUD
############################################

echo
echo "=== ROOMS: Create (owner) ==="
CREATE_ROOM_JSON=$(curl -s -X POST "${BASE_URL}/rooms" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${OWNER_TOKEN}" \
  -d '{
    "title": "Przytulny apartament",
    "body": "Blisko centrum, 2 pokoje, wifi.",
    "city": "Kraków",
    "startAt": "2025-09-20T12:00:00.000Z",
    "endsAt": "2025-09-22T10:00:00.000Z"
  }')

echo "$CREATE_ROOM_JSON" | jq .
ROOM_ID=$(echo "$CREATE_ROOM_JSON" | jq -r '._id')
echo "ROOM_ID=${ROOM_ID}"

echo
echo "=== ROOMS: List all ==="
curl -s "${BASE_URL}/rooms" | jq '.[0]'

echo
echo "=== ROOMS: Get by id ==="
curl -s "${BASE_URL}/rooms/${ROOM_ID}" | jq .

echo
echo "=== ROOMS: Update (owner) ==="
curl -s -X PUT "${BASE_URL}/rooms/${ROOM_ID}" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${OWNER_TOKEN}" \
  -d '{
    "title": "Przytulny apartament z balkonem",
    "body": "Blisko centrum, 2 pokoje, wifi, balkon."
  }' | jq .

echo
echo "=== ROOMS: Update (guest) — spodziewany 403 ==="
curl -s -o /dev/stderr -w "HTTP %{http_code}\n" -X PUT "${BASE_URL}/rooms/${ROOM_ID}" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${GUEST_TOKEN}" \
  -d '{"title":"Niedozwolona zmiana"}'

############################################
# 4) ROOMS — Reakcje (like/dislike)
############################################

echo
echo "=== ROOMS: Guest like ==="
curl -s -X POST "${BASE_URL}/rooms/${ROOM_ID}/like" \
  -H "Authorization: Bearer ${GUEST_TOKEN}" | jq .

echo
echo "=== ROOMS: Guest ponowny like — spodziewany 400 ==="
curl -s -o /dev/stderr -w "HTTP %{http_code}\n" -X POST "${BASE_URL}/rooms/${ROOM_ID}/like" \
  -H "Authorization: Bearer ${GUEST_TOKEN}"

echo
echo "=== ROOMS: Guest dislike (zmiana z like) ==="
curl -s -X POST "${BASE_URL}/rooms/${ROOM_ID}/dislike" \
  -H "Authorization: Bearer ${GUEST_TOKEN}" | jq .

############################################
# 5) ROOMS — Rezerwacja
############################################

echo
echo "=== ROOMS: Owner próbuje zarezerwować własny pokój — 403 ==="
curl -s -o /dev/stderr -w "HTTP %{http_code}\n" -X POST "${BASE_URL}/rooms/${ROOM_ID}/reserve" \
  -H "Authorization: Bearer ${OWNER_TOKEN}"

echo
echo "=== ROOMS: Guest rezerwuje pokój (OK) ==="
curl -s -X POST "${BASE_URL}/rooms/${ROOM_ID}/reserve" \
  -H "Authorization: Bearer ${GUEST_TOKEN}" | jq .

echo
echo "=== ROOMS: Guest próbuje zarezerwować ponownie — 409 ==="
curl -s -o /dev/stderr -w "HTTP %{http_code}\n" -X POST "${BASE_URL}/rooms/${ROOM_ID}/reserve" \
  -H "Authorization: Bearer ${GUEST_TOKEN}"

############################################
# 6) ROOMS — Delete
############################################

echo
echo "=== ROOMS: Delete (guest) — 403 ==="
curl -s -o /dev/stderr -w "HTTP %{http_code}\n" -X DELETE "${BASE_URL}/rooms/${ROOM_ID}" \
  -H "Authorization: Bearer ${GUEST_TOKEN}"

echo
echo "=== ROOMS: Delete (owner) — OK ==="
curl -s -o /dev/stderr -w "HTTP %{http_code}\n" -X DELETE "${BASE_URL}/rooms/${ROOM_ID}" \
  -H "Authorization: Bearer ${OWNER_TOKEN}"
