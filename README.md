# pam_2026_p9_ifs23021_fe

## Auth flow

App sekarang memakai alur:

- start app
- cek token lokal
- jika tidak ada token: `LoginPage`
- jika ada token: `GET /auth/me`
- jika valid: masuk ke main menu
- jika `401`: hapus token lalu kembali ke login

## API base URL

Default API:

```text
https://pam-2026-p9-ifs23021.marshalll.fun:8080
```

Bisa dioverride saat run:

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:8080
```

## Flutter Web dan CORS

Kalau dijalankan di Flutter Web, backend wajib mengizinkan CORS untuk origin web app, misalnya:

- `Access-Control-Allow-Origin: http://localhost:63578`
- `Access-Control-Allow-Headers: Content-Type, Authorization`
- `Access-Control-Allow-Methods: GET, POST, OPTIONS`

Tanpa itu, request login `/auth/login` dan validasi `/auth/me` akan diblokir browser sebelum sampai ke handler backend.
