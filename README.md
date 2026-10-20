# بوابة أوسان دو القضائية الذكية | Awsan Dew Judicial Gateway
## المنظومة القضائية والعدلية الدولية الموحدة • إصدار المعمارية v3.0.0 (Sovereign Justice Mesh)

> **"Universal Sovereign Judicial Mesh & Autonomous Court Integration Engine: Digital Notary Public, E-Litigation Dockets, Enforcement Writs, ISO 20022 Interbank Escrow & The Hague e-Apostille."**

مستودع الكود المصدري الرسمي لـ **Awsan Dew Judicial Gateway** — المحرك السحابي المؤتمت لربط المحاكم، كتابات العدل، قضاء التنفيذ، والتحكيم الدولي لـ 190+ دولة بدون تدخل بشري.

---

### 🏛️ إشعار الملكية الفكرية والحقوق القانونية (Intellectual Property & Legal Ownership)
* **المبتكر والمالك الحصري للحقوق:** المهندس / أوسان عادل عبدالباري أحمد سلطان (Eng. Awsan Adel Abdulbari Ahmed Sultan)
* **الدولة:** الجمهورية اليمنية | **رقم الهوية الوطنية:** `01010305468` | **الهاتف الرسمي:** `+967777852433`
* **البريد الإلكتروني:** `awsan.sultan@gmail.com`
* **محفظة الخزينة الرسمية للبروتوكول (1.0% Creator Royalty Vault):** `0x22848f7963Ea954771120d842BD658f12D4Abb43`
* **معرف المشروع السحابي:** `845333755863` (Google Cloud / AI Studio)
* **المستودع الرسمي على GitHub:** [awsan-dew-sovereign-mesh](https://github.com/awsanadelabdulbariahmedsultan-art/awsan-dew-sovereign-mesh)

---

## 📐 التخطيط المعماري والتصميم الهيكلي (System Architecture & Design)

تم تصميم النظام وفق **معمارية المسار المزدوج غير المتزامن (Dual-Track Architecture)** لضمان عدم تعطل المستثمرين أو حركة التجارة عند بطء الاستجابة في السيرفرات الحكومية:

```
                                 ┌──────────────────────────────────────────────┐
                                 │     طلب المستثمر لشراء الصك أو توثيقه        │
                                 └──────────────────────┬───────────────────────┘
                                                        │
                          ┌─────────────────────────────┴─────────────────────────────┐
                          ▼                                                           ▼
        [المسار الأول: التنفيذ اللحظي 0.5 ثانية]                     [المسار الثاني: الربط العدلي غير المتزامن]
   ┌──────────────────────────────────────────────┐           ┌──────────────────────────────────────────────┐
   │  العقد الذكي للخزينة (AwsanDewTreasury.sol)   │           │  محرك التراسل العدلي (Justice Mesh Router)   │
   │  - حجز وتخصيص التوكنات للمستثمر فوراً        │           │  - إرسال حزمة الصك المشفرة لوزارة العدل      │
   │  - إصدار صك الملكية الرقمي المشفر المعتمد     │           │  - مطابقة السجلات وإصدار كود القيد الرسمي    │
   │  - توزيع العوائد ونسبة الخزينة 1.0% آلياً     │           │  - تحديث الباركود الاستعلامي الرسمي للوزارة   │
   │  * المستثمر يستلم صكه فوراً دون أي انتظار   │           │  * يتم في الخلفية السحابية دون تعطيل الشراء  │
   └──────────────────────────────────────────────┘           └──────────────────────────────────────────────┘
```

### مخطط شبكة الربط والتقاطعات الميدانية (Justice Mesh Network Topology)
```
  [ منصات الأصول العقارية RWA ]  <───>  [ راوتر بوابة العدل (FastAPI) ]  <───>  [ مقاسم وزارات العدل والمحاكم ]
               │                                      │                                      │
  (تداول الصكوك وتوزيع العوائد)          (توقيع HMAC-SHA256 & TLS 1.3)          (توثيق، تقاضٍ، تنفيذ، أبوستيل)
```

---
* 📖 **الدليل الفني والهندسي الشامل لفرق تقنية المعلومات بالوزارات:**
  * المسار داخل المستودع: [`MINISTRY_OF_JUSTICE_INTEGRATION_MANUAL.md`](./MINISTRY_OF_JUSTICE_INTEGRATION_MANUAL.md)
  * رابط العرض المباشر على GitHub:  
    👉 **[فتح الدليل الفني الشامل على GitHub](https://github.com/awsanadelabdulbariahmedsultan-art/awsan-dew-judicial-gateway/blob/main/MINISTRY_OF_JUSTICE_INTEGRATION_MANUAL.md)**
* 📜 **وثيقة الترخيص وحماية الملكية الفكرية ونسبة الخزينة (1.0%):** [`LICENSE`](./LICENSE)
* ⚙️ **نموذج إعداد المتغيرات البيئية الآمن:** [`.env`](./.env)


## 📌 محتويات المستودع وهيكل الملفات (Repository Structure)

| اسم الملف | الوصف والدور التقني |
| :--- | :--- |
| **`universal_justice_mesh_router.py`** | خادم وراوتر بايثون (FastAPI + Web3) لتنفيذ خدمات التوثيق، قيد الدعاوى، التنفيذ القضائي، والمزامنة السحابية. |
| **`MINISTRY_OF_JUSTICE_INTEGRATION_MANUAL.md`** | الدليل الفني والهندسي الشامل الموجه لفرق تقنية المعلومات بالوزارات لربط قواعد البيانات ومقاسم التوثيق. |
| **`LICENSE`** | وثيقة الترخيص السيادي التجاري الخاص وحماية الملكية الفكرية ونسبة الخزينة (1.0%). |
| **`.gitignore`** | ملف استبعاد المفاتيح والبيئات المؤقتة من التتبع على Git و GitHub لحماية الأسرار. |
| **`protocol.js`** | مكتبة الربط البرمجي للعميل (SDK v3.0.0) المتضمنة دوال التقاضي والتوثيق والأبوستيل الدولي. |
| **`digital_bank_config.json`** | ملف تكوين المقاصة وسجل الجهات العدلية والسجلات العقارية لـ 190+ دولة. |
| **`requirements.txt`** | متطلبات تشغيل خادم البايثون (FastAPI, Web3, Uvicorn, Cryptography). |
| **`.env.example`** | نموذج المتغيرات البيئية ومفاتيح الربط المخصصة لوزارة العدل. |

---

## ⚡ المعمارية التشغيلية (The 6 Judicial Pillars)

1. 📜 **التوثيق وكتابات العدل (Digital Notary & Title Attestation):** إصدار محررات البيع والتنازل وتوليد كود الحماية السري (`JUD-SEC-XXXX-XXXX`) والباركود الاستعلامي الرسمي لمكافحة التزوير.
2. ⚖️ **المحاكم والتقاضي الإلكتروني (E-Litigation & Virtual Courts):** قيد الدعاوى وإصدار رقم القضية وتوليد روابط غرف الجلسات الافتراضية المشفرة للخصوم والقضاة.
3. ⚡ **قضاء التنفيذ والأوامر القضائية الذكية (Smart Enforcement Writs):** أتمتة الحجز والفك التلقائي للأصول والتوكنات بالبلوكتشين عبر مقاسم البنوك المركزية فور صدور الحكم.
4. 🤝 **التراضي والمصالحة والتحكيم الدولي (Mediation & ADR):** توثيق محاضر الصلح وإكسابها صفة السند التنفيذي وفق اتفاقية سنغافورة 2019.
5. 📂 **التركات وحصر الورثة (Estate & Inheritance Allocations):** قسمة التركات العقارية آلياً وتوليد صكوك فرعية تسلسلية لكل وارث بنسب تملك دقيقة.
6. 🌐 **الأبوستيل والتصديق الدولي (The Hague e-Apostille):** إصدار شهادة الأبوستيل المعتمدة دولياً في أكثر من 120 دولة عضو لاتفاقية لاهاي 1961 ومعايير UNCITRAL MLETR.

---

## 🛠️ دليل الربط والتشغيل السريع لفرق تقنية المعلومات بالوزارات والمحاكم (Ministry Deployment & Integration Guide)

يمكن لمهندسي وفرق تقنية المعلومات بوزارات العدل والمحاكم تشغيل الراوتر وربطه مع أنظمتهم الميدانية عبر الخطوات التالية:

### الخطوة 1: استنساخ المستودع (Clone Repository)
```bash
git clone https://github.com/awsanadelabdulbariahmedsultan-art/awsan-dew-judicial-gateway.git
cd awsan-dew-judicial-gateway
```

### الخطوة 2: تثبيت المتطلبات البرمجية
```bash
pip install -r requirements.txt
```

### الخطوة 3: إعداد المتغيرات البيئية للمشروع
```bash
cp .env.example .env
```
*قم بتعديل ملف `.env` وضبط المعرف والتوكن المخصص لوزارتكم الموقرة:*
```env
MOJ_API_ENDPOINT="https://api.awsan-dew.com/v1/justice"
MOJ_CLIENT_ID="<YOUR_MINISTRY_CLIENT_ID>"
MOJ_BEARER_TOKEN="<YOUR_MINISTRY_BEARER_TOKEN>"
MOJ_HMAC_SECRET="<YOUR_MINISTRY_HMAC_SECRET>"
```
> **ملاحظة أمنية سيادية:** يتم تزويد كل وزارة ومحكمة ببيانات الاعتماد وتوكن المصادقة المشفر الخاص بها (`Dedicated Bearer Token`) ومفتاح التوقيع الرقمي (`HMAC Secret`) بشكل سري ومستقل عبر القنوات الرسمية عند اعتماد اتفاقية الربط.

### الخطوة 4: تشغيل خادم بوابة العدل (Run Gateway Server)
```bash
python universal_justice_mesh_router.py
```
*أو عبر Uvicorn بالمنفذ المفضل:*
```bash
uvicorn universal_justice_mesh_router:app --host 0.0.0.0 --port 8000 --reload
```

### الخطوة 5: فحص الواجهات التفاعلية (Interactive API Documentation)
بمجرد تشغيل الخادم، يمكن لمهندسي الوزارة استعراض واجهات الـ Swagger UI و ReDoc وتجربة الاستدعاءات مباشرة عبر المتصفح:
* **Swagger UI:** `http://localhost:8000/docs`
* **ReDoc Documentation:** `http://localhost:8000/redoc`
* **Health Check:** `http://localhost:8000/health`

---

## 📡 نموذج استدعاء الـ API لفريق تقنية المعلومات بالوزارات (Ministry API Call Example)

تستطيع أنظمة وزارة العدل مزامنة وقيد أي صك أو محرر بيع عقاري آلياً عبر إرسال طلب `POST` مشفر:

### 1. عبر cURL (Terminal / Bash):
```bash
curl -X POST "http://localhost:8000/v1/justice/notary-escrow-sync"      -H "Content-Type: application/json"      -H "Authorization: Bearer <YOUR_MINISTRY_BEARER_TOKEN>"      -H "X-Signature: HMAC-SHA256 <DIGITAL_SIGNATURE_HASH>"      -d '{
       "protocol": "Awsan Dew Sovereign RWA Notary Bridge v3.0.0",
       "deedId": "AWD-YE-ADE-TWR-305468",
       "courtJurisdiction": "محكمة صيرة وكتابة عدل محافظة عدن",
       "judicialRecordNo": "1448/2026/توثيق",
       "notaryDocumentType": "محرر بيع قطعي وتنازل رسمي معتمد",
       "investorIdentity": {
         "fullName": "أوسان عادل عبدالباري أحمد سلطان",
         "nationalId": "01010305468",
         "walletAddress": "0x22848f7963Ea954771120d842BD658f12D4Abb43"
       }
     }'
```

### 2. عبر Python (Requests):
```python
import requests

url = "http://localhost:8000/v1/justice/notary-escrow-sync"
headers = {
    "Authorization": "Bearer <YOUR_MINISTRY_BEARER_TOKEN>",
    "Content-Type": "application/json"
}
payload = {
    "protocol": "Awsan Dew Sovereign RWA Notary Bridge v3.0.0",
    "deedId": "AWD-YE-ADE-TWR-305468",
    "courtJurisdiction": "محكمة صيرة وكتابة عدل محافظة عدن",
    "judicialRecordNo": "1448/2026/توثيق",
    "notaryDocumentType": "محرر بيع قطعي وتنازل رسمي معتمد",
    "investorIdentity": {
        "fullName": "أوسان عادل عبدالباري أحمد سلطان",
        "nationalId": "01010305468",
        "walletAddress": "0x22848f7963Ea954771120d842BD658f12D4Abb43"
    }
}

response = requests.post(url, json=payload, headers=headers)
print("Response Status:", response.status_code)
print("Response JSON:", response.json())
```

---

## 🔒 الأمان والمصادقة السيادية (Security Standards)
* **بروتوكول النقل المشفر:** TLS 1.3 مع دعم شهادات الأمان الثنائية mTLS.
* **المصادقة الثنائية بالتوكن:** Bearer Token مخصص ومستقل لكل وزارة وهيئة توثيق (`HTTPBearer`).
* **التوقيع الرقمي:** مطابقة ترويسة `X-Signature` باستخدام خوارزمية `HMAC-SHA256` لمنع التلاعب في حزم البيانات المنقولة.
* **الختم الزمني المشفر:** متوافق مع معيار `RFC 3161 Trusted Timestamping`.
* **عزل المستأجرين (Multi-Tenant Isolation):** فصل كامل بين بيانات وسجلات الوزارات والدول لضمان السيادة الرقمية التامة.

---
جميع الحقوق الفكرية والتجارية والبرمجية محفوظة © 2026 للمهندس / أوسان عادل عبدالباري أحمد سلطان.
