#!/usr/bin/env bash
set -euo pipefail

ENV_SOURCE="${ENV_SOURCE:-.env.local}"
if [[ -f "$ENV_SOURCE" ]]; then
  set +u
  set -a
  source "$ENV_SOURCE"
  set +a
  set -u
fi

BASE_URL="${EVOLUTION_PROXY_BASE_URL:-http://localhost:${EVOLUTION_PROXY_HTTP_PORT:-8088}}"
AUTH_KEY="${EVOLUTION_AUTH_KEY:-${AUTHENTICATION_API_KEY:-}}"
INSTANCE_NAME="${1:-${EVOLUTION_INSTANCE_NAME:-default}}"
QR_OUTPUT="${QR_OUTPUT:-}"  # opcional
INSTANCE_TOKEN="${EVOLUTION_INSTANCE_TOKEN:-${AUTH_KEY:-${INSTANCE_NAME}}}"
INSTANCE_INTEGRATION="${EVOLUTION_INSTANCE_INTEGRATION:-WHATSAPP-BAILEYS}"
CONNECT_ATTEMPTS="${EVOLUTION_QR_ATTEMPTS:-6}"
CONNECT_INTERVAL="${EVOLUTION_QR_INTERVAL_SECONDS:-10}"
CREATE_ATTEMPTS="${EVOLUTION_CREATE_ATTEMPTS:-3}"
CREATE_INTERVAL="${EVOLUTION_CREATE_INTERVAL_SECONDS:-5}"

for cmd in curl jq base64; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "error: dependência '$cmd' não encontrada no PATH." >&2
    exit 3
  fi
done



if [[ -z "$AUTH_KEY" ]]; then
  echo "error: AUTHENTICATION_API_KEY ou EVOLUTION_AUTH_KEY não definido." >&2
  exit 1
fi

API_HEADERS=(-H "Authorization: Bearer $AUTH_KEY" -H "apikey: $AUTH_KEY")

create_payload=$(jq -n \
  --arg name "$INSTANCE_NAME" \
  --arg token "$INSTANCE_TOKEN" \
  --arg integration "$INSTANCE_INTEGRATION" \
  '{
    instanceName: $name,
    token: $token,
    qrcode: true,
    integration: $integration
  }'
)

create_instance() {
  local tmp status
  tmp="$(mktemp)"
  status=$(curl -sS \
    -H "Content-Type: application/json" \
    "${API_HEADERS[@]}" \
    -o "$tmp" -w "%{http_code}" \
    -X POST "$BASE_URL/instance/create" \
    --data "$create_payload" || echo "000")
  echo "$status" "$tmp"
}

delete_instance() {
  local tmp status
  tmp="$(mktemp)"
  status=$(curl -sS \
    "${API_HEADERS[@]}" \
    -o "$tmp" -w "%{http_code}" \
    -X DELETE "$BASE_URL/instance/delete/$INSTANCE_NAME" || echo "000")

  if [[ "$status" != "200" && "$status" != "204" ]]; then
    echo "warning: falha ao remover instância existente (HTTP $status)." >&2
    cat "$tmp" >&2
    rm -f "$tmp"
    return 1
  fi

  echo "==> Instância '$INSTANCE_NAME' removida (HTTP $status)." >&2
  rm -f "$tmp"
  return 0
}

CREATE_ATTEMPT=1
CREATE_HTTP=""
CREATE_TMP=""

while [[ $CREATE_ATTEMPT -le $CREATE_ATTEMPTS ]]; do
  read CREATE_HTTP CREATE_TMP < <(create_instance)

  if [[ "$CREATE_HTTP" == "000" ]]; then
    echo "error: falha ao conectar ao endpoint /instance/create." >&2
    rm -f "$CREATE_TMP"
    exit 1
  fi

  if [[ "$CREATE_HTTP" == "403" ]] && grep -qi 'already in use' "$CREATE_TMP"; then
    echo "==> Instância '$INSTANCE_NAME' já existe; reiniciando..." >&2
    if delete_instance; then
      rm -f "$CREATE_TMP"
      sleep "$CREATE_INTERVAL"
      CREATE_ATTEMPT=$((CREATE_ATTEMPT + 1))
      continue
    else
      echo "error: não foi possível remover a instância existente." >&2
      rm -f "$CREATE_TMP"
      exit 1
    fi
  fi

  break
done

if [[ "$CREATE_HTTP" == "403" ]]; then
  echo "error: criação da instância falhou após ${CREATE_ATTEMPT} tentativas (HTTP 403)." >&2
  cat "$CREATE_TMP" >&2
  rm -f "$CREATE_TMP"
  exit 1
fi

if [[ "$CREATE_HTTP" != "200" && "$CREATE_HTTP" != "201" && "$CREATE_HTTP" != "409" ]]; then
  echo "error: criação da instância retornou HTTP $CREATE_HTTP." >&2
  cat "$CREATE_TMP" >&2
  rm -f "$CREATE_TMP"
  exit 1
fi

if [[ "$CREATE_HTTP" == "409" ]]; then
  echo "==> Instância '$INSTANCE_NAME' já existente; reutilizando..." >&2
else
  echo "==> Instância '$INSTANCE_NAME' criada (HTTP $CREATE_HTTP)." >&2
  cat "$CREATE_TMP" >&2
fi

rm -f "$CREATE_TMP"

CONNECT_TMP="$(mktemp)"
SUCCESS=false

for attempt in $(seq 1 "$CONNECT_ATTEMPTS"); do
  CONNECT_HTTP=$(curl -sS \
    "${API_HEADERS[@]}" \
    -o "$CONNECT_TMP" -w "%{http_code}" \
    "$BASE_URL/instance/connect/$INSTANCE_NAME" || echo "000")

  if [[ "$CONNECT_HTTP" != "200" ]]; then
    echo "error: falha ao conectar instância (HTTP $CONNECT_HTTP)." >&2
    cat "$CONNECT_TMP" >&2
    rm -f "$CONNECT_TMP"
    exit 1
  fi

  qr_base64=$(jq -r '
    .qrcode.base64? //
    .qrcode.qrCode? //
    .qrcode? //
    .qrCode? //
    .qr_code? //
    .base64? //
    empty
  ' "$CONNECT_TMP")

  if [[ -n "$qr_base64" && "$qr_base64" != "null" ]]; then
    SUCCESS=true
    break
  fi

  echo "==> QR code ainda não disponível (tentativa ${attempt}/${CONNECT_ATTEMPTS}); aguardando ${CONNECT_INTERVAL}s..."
  sleep "$CONNECT_INTERVAL"
done

if ! $SUCCESS; then
  echo "error: QR code não retornado após ${CONNECT_ATTEMPTS} tentativas." >&2
  cat "$CONNECT_TMP" >&2
  rm -f "$CONNECT_TMP"
  exit 1
fi

echo "QR Code base64:"
echo "$qr_base64"

python3 - "$qr_base64" "$RENDER_SIZE" "${QR_OUTPUT:-}" <<'PY'
import base64
import struct
import sys
import zlib

def paeth(a, b, c):
    p = a + b - c
    pa = abs(p - a)
    pb = abs(p - b)
    pc = abs(p - c)
    if pa <= pb and pa <= pc:
        return a
    if pb <= pc:
        return b
    return c

def decode_png(data):
    if not data.startswith(b"\x89PNG\r\n\x1a\n"):
        raise ValueError("not a png")
    idx = 8
    width = height = bitdepth = colortype = None
    idat = bytearray()
    while idx < len(data):
        length = struct.unpack(">I", data[idx:idx+4])[0]
        ctype = data[idx+4:idx+8]
        chunk = data[idx+8:idx+8+length]
        idx += 12 + length
        if ctype == b'IHDR':
            width, height, bitdepth, colortype, comp, flt, inter = struct.unpack(">IIBBBBB", chunk)
            if inter != 0 or comp != 0 or flt != 0:
                raise ValueError("unsupported png format")
        elif ctype == b'IDAT':
            idat.extend(chunk)
        elif ctype == b'IEND':
            break
    if None in (width, height, bitdepth, colortype):
        raise ValueError("invalid png")
    raw = zlib.decompress(bytes(idat))
    channels_map = {0: 1, 2: 3, 3: 1, 4: 2, 6: 4}
    if colortype not in channels_map:
        raise ValueError("unsupported color type")
    channels = channels_map[colortype]
    bpp = (bitdepth * channels + 7) // 8
    stride = width * bpp
    rows = []
    i = 0
    for _ in range(height):
        filter_type = raw[i]
        i += 1
        row = bytearray(raw[i:i+stride])
        i += stride
        recon = bytearray(stride)
        prev = rows[-1] if rows else bytearray(stride)
        if filter_type == 0:
            recon[:] = row
        elif filter_type == 1:
            for x in range(stride):
                left = recon[x - bpp] if x >= bpp else 0
                recon[x] = (row[x] + left) & 0xFF
        elif filter_type == 2:
            for x in range(stride):
                recon[x] = (row[x] + prev[x]) & 0xFF
        elif filter_type == 3:
            for x in range(stride):
                left = recon[x - bpp] if x >= bpp else 0
                up = prev[x]
                recon[x] = (row[x] + ((left + up) >> 1)) & 0xFF
        elif filter_type == 4:
            for x in range(stride):
                left = recon[x - bpp] if x >= bpp else 0
                up = prev[x]
                up_left = prev[x - bpp] if x >= bpp else 0
                recon[x] = (row[x] + paeth(left, up, up_left)) & 0xFF
        else:
            raise ValueError("unsupported filter")
        rows.append(recon)
    pixels = []
    for row in rows:
        line = []
        for x in range(width):
            px = row[x * bpp:(x + 1) * bpp]
            if colortype in (0, 3):
                val = px[0]
            elif colortype == 2:
                val = sum(px[:3]) // 3
            elif colortype == 4:
                val = px[0]
            elif colortype == 6:
                r, g, b, a = px
                val = (r + g + b) // 3 if a else 255
            else:
                val = px[0]
            line.append(val)
        pixels.append(line)
    return pixels

def trim(pixels, threshold=128):
    height = len(pixels)
    width = len(pixels[0])
    top = 0
    while top < height and all(v >= threshold for v in pixels[top]):
        top += 1
    bottom = height - 1
    while bottom >= 0 and all(v >= threshold for v in pixels[bottom]):
        bottom -= 1
    left = 0
    while left < width and all(row[left] >= threshold for row in pixels):
        left += 1
    right = width - 1
    while right >= 0 and all(row[right] >= threshold for row in pixels):
        right -= 1
    if top >= bottom or left >= right:
        return pixels
    return [row[left:right+1] for row in pixels[top:bottom+1]]

def to_ascii(pixels, threshold=128):
    trimmed = trim(pixels, threshold)
    rows = len(trimmed)
    cols = len(trimmed[0])
    if rows % 2 == 1:
        trimmed.append([255] * cols)
        rows += 1
    margin = "  "
    lines = []
    for y in range(0, rows, 2):
        upper = trimmed[y]
        lower = trimmed[y + 1]
        row_chars = [margin]
        for x in range(cols):
            top_dark = upper[x] < threshold
            bottom_dark = lower[x] < threshold
            if top_dark and bottom_dark:
                ch = "█"
            elif top_dark and not bottom_dark:
                ch = "▀"
            elif not top_dark and bottom_dark:
                ch = "▄"
            else:
                ch = " "
            row_chars.append(ch * 2)
        lines.append("".join(row_chars))
    return "\n".join(lines)

def resize_nearest(pixels, size):
    if size <= 0:
        return pixels
    src_h = len(pixels)
    src_w = len(pixels[0]) if src_h else 0
    if src_h == 0 or src_w == 0 or size == src_h:
        return pixels
    result = []
    for y in range(size):
        src_y = int(y * src_h / size)
        if src_y >= src_h:
            src_y = src_h - 1
        row = []
        for x in range(size):
            src_x = int(x * src_w / size)
            if src_x >= src_w:
                src_x = src_w - 1
            row.append(pixels[src_y][src_x])
        result.append(row)
    return result

def encode_png(pixels):
    height = len(pixels)
    width = len(pixels[0]) if height else 0
    if height == 0 or width == 0:
        raise ValueError("invalid image size")
    def chunk(tag, data):
        return struct.pack(">I", len(data)) + tag + data + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)
    ihdr = struct.pack(">IIBBBBB", width, height, 8, 0, 0, 0, 0)
    raw = bytearray()
    for row in pixels:
        raw.append(0)
        raw.extend(row)
    idat = zlib.compress(bytes(raw), level=9)
    return b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", ihdr) + chunk(b"IDAT", idat) + chunk(b"IEND", b"")

def main():
    raw = sys.argv[1]
    target_size = int(sys.argv[2]) if len(sys.argv) > 2 and sys.argv[2] else 0
    output_path = sys.argv[3] if len(sys.argv) > 3 else ""
    if "," in raw:
        raw = raw.split(",", 1)[1]
    try:
        data = base64.b64decode(raw)
        pixels = decode_png(data)
        trimmed = trim(pixels)
        resized = resize_nearest(trimmed, target_size) if target_size else trimmed
        ascii_qr = to_ascii(resized)
        print("\nASCII QR:")
        print(ascii_qr)
        if output_path:
            try:
                png_bytes = encode_png(resized)
                with open(output_path, "wb") as fh:
                    fh.write(png_bytes)
                print(f"QR redimensionado salvo em {output_path}")
            except Exception as exc:
                print(f"warning: não foi possível salvar PNG redimensionado ({exc}).", file=sys.stderr)
    except Exception as exc:
        print(f"warning: não foi possível renderizar QR no terminal ({exc}).", file=sys.stderr)

if __name__ == "__main__":
    main()
PY

cat "$CONNECT_TMP"
rm -f "$CONNECT_TMP"
