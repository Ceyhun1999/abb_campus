# Final Layihə — Tələblər və Qiymətləndirmə

## ⚠️ Məcburi şərtlər

Bu şərtlərdən biri ödənməsə, layihə qiymətləndirməyə qəbul olunmur:

- Layihə SwiftUI ilə yazılır (UIKit yalnız SwiftUI-da olmayan komponent lazım olanda `UIViewRepresentable` kimi istifadə oluna bilər).
- Arxitektura MVVM-dir: View-da business logic, networking və ya data emalı olmur.
- Ən azı bir feature-un ViewModelləri üçün unit testlər yazılsın və həmin feature-un View-su üçün UI test yazılsın.
- Kod GitHub-dadır və README var (öz reponuzda, ABB Organization daxilində yox). Bütün app 1 commitlə deyil, mənalı commitlərlə yazılıb.
- GitHub Actions workflow yaradın — hər push və pull request-də testlər avtomatik run olunsun. Actions tab-ında son run yaşıl ✅ olmalıdır.

## 👨‍💻 1. Təlimçi qiymətləndirməsi — 60 bal

Bu hissə Demo Day-dən əvvəl aparılır.

### 1️⃣ Arxitektura və kod keyfiyyəti — 20

- MVVM düzgün tətbiq olunub: View → ViewModel → Service/Repository
- Naming: aydın və ardıcıl adlar
- File structure: məntiqi qovluqlar
- Komponentlərə bölünmə: böyük View-lar kiçik, təkrar istifadə olunan View-lara bölünüb
- Code reusability: eyni kod copy-paste olunmayıb, ortaq hissələr extension, komponent və ya helper-ə çıxarılıb
- OOP / SOLID: protocol-lar, dependency injection, hər class-ın bir məsuliyyəti var

### 2️⃣ Funksionallıq — 12

- App işləyir, crash yoxdur
- Feature-lar tamamlanıb
- Loading, error və empty state-lər idarə olunub

### 3️⃣ iOS konseptlərinin istifadəsi — 10

- Networking (async/await)
- State management (`@State`, `@Binding`, `@Observable` / `ObservableObject`)
- Navigation (`NavigationStack`, sheet, `TabView`)
- Persistence (SwiftData, UserDefaults və s.)

### 4️⃣ Unit test — 8

- Ən azı 1 ViewModel test olunub (minimum 4–5 test)
- Həm uğurlu (success), həm xəta (error) halı yoxlanılıb
- Service protocol ilə mock olunub, testlər real API-yə müraciət etmir
- Testlər keçir (yaşıl ✅)

### 5️⃣ UI implementasiyası — 5

- SwiftUI layout düzgün qurulub (stack-lar, spacing, padding)
- Müxtəlif ekran ölçülərində düzgün görünür
- Dark mode da var

### 6️⃣ Git və layihə strukturu — 5

- Mənalı commit-lər
- Commit-lər zamana yayılıb, bütün kod bir commit-də deyil
- README: app nədir, screenshot-lar, istifadə olunan texnologiyalar, necə run etmək

**Cəmi: 60**

## 🏆 2. Demo Day — Münsiflər — 40 bal

### 1️⃣ Texniki mürəkkəblik — 15

Networking, state management, navigation, persistence və app-in ümumi texniki səviyyəsi.

### 2️⃣ İcra keyfiyyəti və UI/UX — 15

App stabil işləyir, navigation problemi yoxdur, UI səliqəlidir, istifadəsi rahatdır.

### 3️⃣ Təqdimat — 10

Strukturlaşdırılmış təqdimat, vaxtdan düzgün istifadə, demo-nun rahat göstərilməsi, qərarların izahı.
Burada tələbədən bir sual da gözlənilir: "Niyə bu arxitekturanı seçdin, nəyi test etdin?"

**Cəmi: 40**
