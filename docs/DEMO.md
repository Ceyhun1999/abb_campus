# Demo Day — təqdimat planı

Bu sənəd Demo Day üçündür: nəyi hansı ardıcıllıqla göstərmək, hansı hesabla daxil olmaq və münsiflərin «Niyə bu arxitekturanı seçdin, nəyi test etdin?» sualına necə cavab vermək.

## 1. Hazırlıq (təqdimatdan əvvəl)

- Tətbiq canlı serverlə işləyir: `https://campus.jeywastudio.com`. İnternet olmalıdır.
- Canlı bazada demo qrupu hazırdır: **IOS-01** (Mobile Development iOS).
  - Müəllim: Rashad Mammadov (`teacher@abb.local`), mentor: Fidan Kərimova.
  - 6 tələbə, o cümlədən `student@abb.local`.
  - 05.10–20.11 cədvəli: 21 dərs, B.e./Ç./C. 19:00–21:00.
  - 05–16 oktyabr üçün davamiyyət, oktyabrın 3 tapşırığının balları.
  - «Modul 1 imtahanı» (17.10) balları ilə və 23.11-ə təyin edilmiş «Modul 2 imtahanı».
  - 21.10 dərsi «Müəllim xəstədir» səbəbi ilə ləğv edilib.
- Login 5 cəhd/dəqiqə ilə məhdudlaşdırılıb. Şifrəni səhv yazsanız, bir dəqiqə gözləyin.

| Rol | E-poçt | Şifrə |
|---|---|---|
| Tələbə | `student@abb.local` | `Password123!` |
| Müəllim | `teacher@abb.local` | `Password123!` |
| İşçi | `employee@abb.local` | `abc12345` |

**Ehtiyat plan (internet olmasa):** Xcode → Product → Scheme → Edit Scheme → Run → Arguments → `-ui-testing` əlavə edin. Tətbiq server olmadan, yaddaşdakı demo məlumatı ilə açılır. Bu rejimdə hər üç hesabın şifrəsi `Password123!`-dir.

## 2. Demo ssenarisi (~7 dəqiqə)

1. **Giriş (30 san.).** Rol seçimi → tələbə kimi daxil olun. Sessiya Keychain-də saxlanılır: tətbiqi bağlayıb açsanız, yenidən daxil olmaq lazım deyil.
2. **Tələbə (1,5 dəq.).**
   - Ana səhifə: növbəti dərs (ləğv olunmuş 21.10 dərsini keçir), orta bal, davamiyyət, son elanlar.
   - **Cədvəl:** ləğv olunmuş dərs səbəbi ilə və imtahanlar.
   - **Qiymətlər → Aylıq ballar:** oktyabrın tapşırıq və imtahan balları.
   - **Bildirişlər:** qrupa gələn avtomatik bildirişlər (dərs ləğv edildi, yeni imtahan).
3. **Müəllim (2,5 dəq.).**
   - Ana səhifə: qruplar, tələbələr, növbəti dərslər.
   - **Qruplar → IOS-01 → Dərs cədvəli:** dərsi sola sürüşdürün → **Ləğv et** → səbəb seçin. Tələbələrə bildiriş gedir. Sonra **Bərpa et**.
   - **Davamiyyət:** ay üzrə hər tələbənin faizi; «Excel-dən davamiyyət yüklə».
   - **Ballar** və **İmtahanlar:** imtahan təyin edin. O, dərhal tələbənin cədvəlində və bildirişlərində görünür.
4. **İşçi (2 dəq.).**
   - Ana səhifə və siyahılar: axtarış, filtr, səhifələmə.
   - **Qruplar → IOS-01 → Dərs cədvəli → Excel-dən cədvəl idxal et** → `cedvel_sehvli.xlsx`: səhvlər sətir-sətir göstərilir, cədvəl dəyişmir. (Səhvsiz fayl bu qrupun cədvəlini yeniləyər. Göstərmək istəsəniz, `cedvel.xlsx` yalnız 05–30.10 aralığını əvəz edir.)
   - **Elanlar:** prioritet, auditoriya, linklər; redaktə və silmə.
5. **Dark mode (15 san.).** Profil → **Görünüş**: «Qaranlıq» və «İşıqlı» bütün tətbiqi dərhal dəyişir, «Sistem» telefonun ayarına qayıdır. Seçim yadda qalır.
6. **GitHub (30 san.).** Actions-da son yaşıl run, README-dəki şəkillər, mənalı commitlər.

## 3. «Niyə bu arxitekturanı seçdin?»

**MVVM + Service + protokollar + dependency injection.**

- **View** yalnız state-i göstərir və istifadəçinin hərəkətini ViewModel-ə ötürür. View-da networking, validasiya və data emalı yoxdur.
- **ViewModel** (`@Observable`, `@MainActor`) ekranın vəziyyətini saxlayır, validasiya edir və servisləri çağırır. UI-dan asılı deyil, ona görə unit testlə yoxlanılır.
- **Service-lər protokolun arxasındadır** (`GroupService`, `TeachingService`, `LessonService`…). Real tətbiqdə `Default…` sinifləri serverə gedir, testlərdə isə mock-lar işləyir. Bu, SOLID-in Dependency Inversion prinsipidir.
- **`AppDependencies` kompozisiya kökü:** bütün servislər bir yerdə yaradılır. `-ui-testing` arqumenti ilə eyni tətbiq stub servislərlə işləyir və UI testlər serverdən asılı olmur.
- **Təkrar istifadə:** ümumi komponentlər (`AsyncContentView`, `LessonRow`, `StatusActionButton`, `DashboardTile`…) və ümumi məntiq:
  - `LoadableValue`: ekranın yüklənməsi, köhnə cavabların atılması, ləğvin emalı;
  - `PagedList`: səhifələmə;
  - `DebouncedSearch`: axtarış;
  - `ImportFlow` və `ImportKind`: beş fərqli Excel importu üçün bir ekran;
  - `GroupScheduleSource`: işçi və müəllim eyni cədvəl ekranından istifadə edir.
- **Niyə `@Observable` (Observation)?** `ObservableObject`-dən sadədir və yalnız istifadə olunan property dəyişəndə View-u yeniləyir.

## 4. «Nəyi test etdin?»

| Növ | Say | Nə yoxlanılır |
|---|---|---|
| Unit testlər (Swift Testing) | 200+ | Bütün ViewModel-lər: uğur və xəta halları, validasiya, səhifələmə, axtarış, importlar, ləğv/bərpa, ay keçidləri, imtahan forması |
| Konkurentlik testləri | daxildir | Gec gələn köhnə cavab yenisini əzmir; ləğv olunmuş yeniləmə ekranı boşaltmır (`PendingCalls` ilə determinik, `sleep` yoxdur) |
| Şəbəkə xətaları | daxildir | 500 (JSON və HTML), 429, timeout, internet yoxdur, səhv JSON, ləğv, təkrar cəhd (`URLProtocol` stub) |
| UI testlər (XCUITest) | 15 | Giriş axını, tələbə, işçi və müəllim ssenariləri, profildə dark/light keçidi (ekran pikselləri ilə yoxlanılır), naviqasiya stress testi (20 dəfə aç/bağla, tab dəyişmə, fon rejimi) |
| Backend (PHPUnit) | 129 | API, icazələr, importlar, tarix qaydaları, sorğu limitləri |
| CI | — | GitHub Actions hər push və pull request-də bütün testləri işlədir |

- Testlər **real API-yə müraciət etmir**: servislər protokol vasitəsilə mock olunur.
- Kod `SWIFT_STRICT_CONCURRENCY=complete` ilə **0 xəbərdarlıqla** yığılır.
- Thread Sanitizer ilə yoxlanılıb, data race tapılmayıb.

## 5. Ola biləcək suallar

- **«Excel faylında səhv olsa nə olur?»** Hamısı və ya heç biri: bir sətirdə belə səhv varsa, heç nə yazılmır və hər səhvin sətir nömrəsi ilə səbəbi göstərilir.
- **«Cədvəli bir dəfəyə yükləmək lazımdır?»** Xeyr. Fayl yalnız öz tarix aralığını əvəz edir, cədvəli ay-ay yükləmək olar. Ləğv olunmuş dərslərin statusu itmir.
- **«Qrupun tarixlərini dəyişsəm?»** Kənarda qalan dərslər varsa, tətbiq əvvəlcə soruşur. Balları yüklənmiş imtahan kənarda qalırsa, dəyişikliyə icazə verilmir.
- **«Persistence harada?»** Token Keychain-də, son istifadə olunan e-poçt və seçilmiş görünüş (Sistem / İşıqlı / Qaranlıq) UserDefaults-da saxlanılır.
- **«Mentor nə edə bilir?»** Müəllimin bacardığı hər şeyi, amma yalnız mentoru olduğu qruplarda.
- **«Təhlükəsizlik?»** Bearer token, rol əsaslı icazələr (policy). Login, şifrə bərpası və API üçün sorğu limitləri var.
