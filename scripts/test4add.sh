#!/bin/zsh
set -euo pipefail

API="http://localhost:3000"

# --- STATUS FLAGS ---
HEALTH_OK=false
REGISTER_OWNER_OK=false
REGISTER_GUEST_OK=false
DUPLICATE_REJECT_OK=false
LOGIN_OWNER_OK=false
LOGIN_GUEST_OK=false
PUBLIC_PROFILE_OK=false
CHECK_EMAIL_OK=false
CHECK_USERNAME_OK=false
USER_PROFILE_OK=false
ROOM_CREATE_OK=false
ROOMS_LIST_OK=false
ROOM_GET_OK=false
ROOM_UPDATE_FORBIDDEN_OK=false
LIKE_OK=false
LIKE_DUPLICATE_REJECT_OK=false
DISLIKE_SWITCH_OK=false
RESERVE_OWNER_FORBIDDEN_OK=false
RESERVE_GUEST_OK=false
RESERVE_DUPLICATE_CONFLICT_OK=false
DELETE_GUEST_FORBIDDEN_OK=false


# helper: status icon
function icon() { [[ $1 == true ]] && echo "✅" || echo "❌" }

# helper: wykonuje curl i ustawia GLOBALNE: BODY, HTTP_CODE
# użycie:
#   curl_json <args...>
#   echo "$BODY"
function curl_json() {
  # brak subshella, wszystko w tej samej powłoce:
  local resp
  resp=$(curl -sSL -w $'\n%{http_code}' "$@")
  HTTP_CODE="${resp##*$'\n'}"    # ostatnia linia = kod
  BODY="${resp%$'\n'*}"          # reszta = JSON body
}

echo "=== 0. Health ==="
curl_json "${API}/health"
echo "$BODY" | jq .
if [[ $(echo "$BODY" | jq -r .status) == "ok" ]]; then
  echo "✅ Health: OK"; HEALTH_OK=true
else
  echo "❌ Health: FAIL (HTTP $HTTP_CODE)"
fi
echo

echo "=== 1. Register owner (owner1) ==="
curl_json -X POST "${API}/auth/register" \
  -H "Content-Type: application/json" \
  -d '{"email":"owner@example.com","username":"owner1","password":"secret12"}'
echo "$BODY" | jq .
OWNER_TOKEN=$(echo "$BODY" | jq -r .token)
OWNER_ID=$(echo "$BODY" | jq -r .user._id)
if [[ -n "$OWNER_TOKEN" && "$OWNER_TOKEN" != "null" ]]; then
  echo "✅ Register owner: OK"; REGISTER_OWNER_OK=true
else
  echo "❌ Register owner: FAIL (HTTP $HTTP_CODE)"
fi
echo

echo "=== 2. Register guest (guest1) ==="
curl_json -X POST "${API}/auth/register" \
  -H "Content-Type: application/json" \
  -d '{"email":"guest@example.com","username":"guest1","password":"secret12"}'
echo "$BODY" | jq .
GUEST_TOKEN_TMP=$(echo "$BODY" | jq -r .token)
GUEST_ID_TMP=$(echo "$BODY" | jq -r .user._id)
if [[ -n "$GUEST_TOKEN_TMP" && "$GUEST_TOKEN_TMP" != "null" ]]; then
  echo "✅ Register guest: OK"; REGISTER_GUEST_OK=true
else
  echo "❌ Register guest: FAIL (HTTP $HTTP_CODE)"
fi
echo

echo "=== 3. Duplicate register (should fail - owner1) ==="
curl_json -X POST "${API}/auth/register" \
  -H "Content-Type: application/json" \
  -d '{"email":"owner@example.com","username":"owner1","password":"secret12"}'
echo "$BODY" | jq .
if [[ "$HTTP_CODE" == "409" || "$HTTP_CODE" == "400" ]]; then
  echo "✅ Duplicate rejected: OK"; DUPLICATE_REJECT_OK=true
else
  echo "❌ Duplicate accepted (HTTP $HTTP_CODE)"
fi
echo

echo "=== 4. Check Email Availability (taken) ==="
curl_json "${API}/auth/checkEmail/owner@example.com"
echo "$BODY" | jq .
if [[ $(echo "$BODY" | jq -r .success) == "false" && "$HTTP_CODE" == "200" ]]; then
  echo "✅ Check Email (taken): OK"; CHECK_EMAIL_OK=true
else
  echo "❌ Check Email (taken): FAIL (HTTP $HTTP_CODE)"
fi
echo

echo "=== 5. Check Email Availability (available) ==="
curl_json "${API}/auth/checkEmail/available@example.com"
echo "$BODY" | jq .
if [[ $(echo "$BODY" | jq -r .success) == "true" && "$HTTP_CODE" == "200" ]]; then
  CHECK_EMAIL_OK=$CHECK_EMAIL_OK
else
  CHECK_EMAIL_OK=false
  echo "❌ Check Email (available): FAIL (HTTP $HTTP_CODE)"
fi
echo

echo "=== 6. Check Username Availability (taken) ==="
curl_json "${API}/auth/checkUsername/owner1"
echo "$BODY" | jq .
if [[ $(echo "$BODY" | jq -r .success) == "false" && "$HTTP_CODE" == "200" ]]; then
  echo "✅ Check Username (taken): OK"; CHECK_USERNAME_OK=true
else
  echo "❌ Check Username (taken): FAIL (HTTP $HTTP_CODE)"
fi
echo

echo "=== 7. Check Username Availability (available) ==="
curl_json "${API}/auth/checkUsername/available_user"
echo "$BODY" | jq .
if [[ $(echo "$BODY" | jq -r .success) == "true" && "$HTTP_CODE" == "200" ]]; then
  CHECK_USERNAME_OK=$CHECK_USERNAME_OK
else
  CHECK_USERNAME_OK=false
  echo "❌ Check Username (available): FAIL (HTTP $HTTP_CODE)"
fi
echo

echo "=== 8. Login owner ==="
curl_json -X POST "${API}/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"username":"owner1","password":"secret12"}'
echo "$BODY" | jq .
OWNER_TOKEN=$(echo "$BODY" | jq -r .token)
OWNER_ID=$(echo "$BODY" | jq -r .user._id)
if [[ -n "$OWNER_TOKEN" && "$OWNER_TOKEN" != "null" ]]; then
  echo "✅ Login owner: OK"; LOGIN_OWNER_OK=true
else
  echo "❌ Login owner: FAIL (HTTP $HTTP_CODE)"
fi
echo "OWNER_ID=$OWNER_ID"
echo

echo "=== 9. Login guest ==="
curl_json -X POST "${API}/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"username":"guest1","password":"secret12"}'
echo "$BODY" | jq .
GUEST_TOKEN=$(echo "$BODY" | jq -r .token)
GUEST_ID=$(echo "$BODY" | jq -r .user._id)
if [[ -n "$GUEST_TOKEN" && "$GUEST_TOKEN" != "null" ]]; then
  echo "✅ Login guest: OK"; LOGIN_GUEST_OK=true
else
  echo "❌ Login guest: FAIL (HTTP $HTTP_CODE)"
fi
echo "GUEST_ID=$GUEST_ID"
echo

echo "=== 10. Public user profile (users/owner1) ==="
curl_json "${API}/users/owner1"
echo "$BODY" | jq .
if [[ $(echo "$BODY" | jq -r .username) == "owner1" ]]; then
  echo "✅ Public profile: OK"; PUBLIC_PROFILE_OK=true
else
  echo "❌ Public profile: FAIL (HTTP $HTTP_CODE)"
fi
echo

echo "=== 11. Current user profile (users/profile) ==="
curl_json "${API}/users/profile" \
  -H "Authorization: Bearer ${OWNER_TOKEN}"
echo "$BODY" | jq .
if [[ $(echo "$BODY" | jq -r .success) == "true" && $(echo "$BODY" | jq -r .data.user.username) == "owner1" ]]; then
  echo "✅ User profile: OK"; USER_PROFILE_OK=true
else
  echo "❌ User profile: FAIL (HTTP $HTTP_CODE)"
fi
echo

echo "=== 12. Create room (as owner) ==="
curl_json -X POST "${API}/rooms" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${OWNER_TOKEN}" \
  -d '{
    "title": "Przytulny apartament",
    "body": "Blisko centrum, 2 pokoje, wifi.",
    "city": "Kraków",
    "startAt": "2025-09-20T12:00:00.000Z",
    "endsAt": "2025-09-22T10:00:00.000Z"
  }'
echo "$BODY" | jq .
ROOM_ID=$(echo "$BODY" | jq -r ._id)
if [[ -n "$ROOM_ID" && "$ROOM_ID" != "null" ]]; then
  echo "✅ Room create: OK (ROOM_ID=$ROOM_ID)"; ROOM_CREATE_OK=true
else
  echo "❌ Room create: FAIL (HTTP $HTTP_CODE)"
fi
echo

echo "=== 13. Rooms list ==="
curl_json "${API}/rooms"
echo "$BODY" | jq '.[0]'
if [[ $(echo "$BODY" | jq -r 'type') == "array" ]]; then
  echo "✅ Rooms list: OK"; ROOMS_LIST_OK=true
else
  echo "❌ Rooms list: FAIL (HTTP $HTTP_CODE)"
fi
echo

echo "=== 14. Room get by id ==="
curl_json "${API}/rooms/${ROOM_ID}"
echo "$BODY" | jq .
if [[ $(echo "$BODY" | jq -r '._id') == "$ROOM_ID" ]]; then
  echo "✅ Room get: OK"; ROOM_GET_OK=true
else
  echo "❌ Room get: FAIL (HTTP $HTTP_CODE)"
fi
echo

echo "=== 15. Update room by guest (should be 403) ==="
UPDATE_GUEST=$(curl -sS -o /dev/null -w "%{http_code}" -X PUT "${API}/rooms/${ROOM_ID}" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${GUEST_TOKEN}" \
  -d '{"title":"Zmiana niedozwolona"}')
echo "HTTP $UPDATE_GUEST"
if [[ "$UPDATE_GUEST" == "403" ]]; then
  echo "✅ Update forbidden for guest: OK"; ROOM_UPDATE_FORBIDDEN_OK=true
else
  echo "❌ Update guest unexpected HTTP $UPDATE_GUEST"
fi
echo

echo "=== 16. Guest LIKE room (expect 200/201) ==="
curl_json -X POST "${API}/rooms/${ROOM_ID}/like" \
  -H "Authorization: Bearer ${GUEST_TOKEN}"
echo "$BODY" | jq .
if [[ "$HTTP_CODE" == "201" || "$HTTP_CODE" == "200" ]]; then
  echo "✅ Like: OK"; LIKE_OK=true
else
  echo "❌ Like: HTTP $HTTP_CODE"
fi
echo

echo "=== 17. Guest LIKE again (should be 400) ==="
LIKE_AGAIN_CODE=$(curl -sS -o /dev/null -w "%{http_code}" -X POST "${API}/rooms/${ROOM_ID}/like" \
  -H "Authorization: Bearer ${GUEST_TOKEN}")
echo "HTTP $LIKE_AGAIN_CODE"
if [[ "$LIKE_AGAIN_CODE" == "400" ]]; then
  echo "✅ Duplicate like rejected: OK"; LIKE_DUPLICATE_REJECT_OK=true
else
  echo "❌ Duplicate like unexpected HTTP $LIKE_AGAIN_CODE"
fi
echo

echo "=== 18. Guest DISLIKE (switch from like) (expect 200/201) ==="
curl_json -X POST "${API}/rooms/${ROOM_ID}/dislike" \
  -H "Authorization: Bearer ${GUEST_TOKEN}"
echo "$BODY" | jq .
if [[ "$HTTP_CODE" == "201" || "$HTTP_CODE" == "200" ]]; then
  echo "✅ Dislike (switch): OK"; DISLIKE_SWITCH_OK=true
else
  echo "❌ Dislike: HTTP $HTTP_CODE"
fi
echo

echo "=== 19. Owner tries to reserve own room (403) ==="
OWNER_RESERVE_CODE=$(curl -sS -o /dev/null -w "%{http_code}" -X POST "${API}/rooms/${ROOM_ID}/reserve" \
  -H "Authorization: Bearer ${OWNER_TOKEN}")
echo "HTTP $OWNER_RESERVE_CODE"
if [[ "$OWNER_RESERVE_CODE" == "403" ]]; then
  echo "✅ Owner reserve forbidden: OK"; RESERVE_OWNER_FORBIDDEN_OK=true
else
  echo "❌ Owner reserve unexpected HTTP $OWNER_RESERVE_CODE"
fi
echo

echo "=== 20. Guest reserves room (expect 200/201) ==="
curl_json -X POST "${API}/rooms/${ROOM_ID}/reserve" \
  -H "Authorization: Bearer ${GUEST_TOKEN}"
echo "$BODY" | jq .
if [[ "$HTTP_CODE" == "201" || "$HTTP_CODE" == "200" ]]; then
  echo "✅ Guest reserve: OK"; RESERVE_GUEST_OK=true
else
  echo "❌ Guest reserve: HTTP $HTTP_CODE"
fi
echo

echo "=== 21. Guest tries to reserve again (409) ==="
RESERVE_AGAIN_CODE=$(curl -sS -o /dev/null -w "%{http_code}" -X POST "${API}/rooms/${ROOM_ID}/reserve" \
  -H "Authorization: Bearer ${GUEST_TOKEN}")
echo "HTTP $RESERVE_AGAIN_CODE"
if [[ "$RESERVE_AGAIN_CODE" == "409" ]]; then
  echo "✅ Duplicate reserve rejected: OK"; RESERVE_DUPLICATE_CONFLICT_OK=true
else
  echo "❌ Duplicate reserve unexpected HTTP $RESERVE_AGAIN_CODE"
fi
echo

echo "=== 22. Delete room as guest (403) ==="
DELETE_GUEST_CODE=$(curl -sS -o /dev/null -w "%{http_code}" -X DELETE "${API}/rooms/${ROOM_ID}" \
  -H "Authorization: Bearer ${GUEST_TOKEN}")
echo "HTTP $DELETE_GUEST_CODE"
if [[ "$DELETE_GUEST_CODE" == "403" ]]; then
  echo "✅ Delete forbidden for guest: OK"; DELETE_GUEST_FORBIDDEN_OK=true
else
  echo "❌ Delete guest unexpected HTTP $DELETE_GUEST_CODE"
fi
echo



# --- SUMMARY ---
echo "=== SUMMARY ==="
echo "Health: $(icon $HEALTH_OK)"
echo "Register: owner=$(icon $REGISTER_OWNER_OK), guest=$(icon $REGISTER_GUEST_OK), duplicateRejected=$(icon $DUPLICATE_REJECT_OK)"
echo "Auth Checks: checkEmail=$(icon $CHECK_EMAIL_OK), checkUsername=$(icon $CHECK_USERNAME_OK)"
echo "Login: owner=$(icon $LOGIN_OWNER_OK), guest=$(icon $LOGIN_GUEST_OK)"
echo "Profiles: public=$(icon $PUBLIC_PROFILE_OK), currentUser=$(icon $USER_PROFILE_OK)"
echo "Room create: $(icon $ROOM_CREATE_OK)"
echo "Rooms list: $(icon $ROOMS_LIST_OK)"
echo "Room get: $(icon $ROOM_GET_OK)"
echo "Room update forbidden (guest): $(icon $ROOM_UPDATE_FORBIDDEN_OK)"
echo "Like: $(icon $LIKE_OK), Duplicate like rejected: $(icon $LIKE_DUPLICATE_REJECT_OK), Dislike switch: $(icon $DISLIKE_SWITCH_OK)"
echo "Reserve: ownerForbidden=$(icon $RESERVE_OWNER_FORBIDDEN_OK), guestOK=$(icon $RESERVE_GUEST_OK), duplicateRejected=$(icon $RESERVE_DUPLICATE_CONFLICT_OK)"
echo "Delete: guestForbidden=$(icon $DELETE_GUEST_FORBIDDEN_OK)"
