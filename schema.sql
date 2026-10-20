-- ==============================================================================
-- Awsan Dew Sovereign Judicial Mesh - Database Schema Architecture v3.0.0
-- منظومة قواعد البيانات السيادية الموحدة لوزارة العدل والهيئات القضائية والمحاكم
-- المبتكر والمالك الحصري للحقوق: المهندس / أوسان عادل عبدالباري أحمد سلطان © 2026
-- الرقم الوطني: 01010305468 | الهاتف: 00967777852433 / 00967776633003
-- محفظة الخزينة السيادية (1.0%): 0x22848f7963Ea954771120d842BD658f12D4Abb43
-- المعايير: ISO 20022, UNCITRAL MLETR, The Hague Apostille 1961, Singapore Convention 2019
-- ==============================================================================

-- ==============================================================================
-- 1. جدول الكوادر القضائية والموارد البشرية والحوكمة الإدارية (Staff & HR IAM)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS staff_users (
    employee_id VARCHAR(32) PRIMARY KEY, -- مثال: EMP-001, EMP-005
    full_name VARCHAR(128) NOT NULL,
    role_title VARCHAR(128) NOT NULL,
    category VARCHAR(32) NOT NULL, -- LEADERSHIP, JUDICIARY, NOTARY, ENFORCEMENT, REGISTRAR, PROSECUTION, ATTORNEY, IT_ADMIN
    department VARCHAR(128) NOT NULL,
    court_jurisdiction VARCHAR(128) NOT NULL,
    national_id VARCHAR(32) UNIQUE NOT NULL,
    phone_number VARCHAR(32) NOT NULL,
    official_vault VARCHAR(64) DEFAULT '0x22848f7963Ea954771120d842BD658f12D4Abb43',
    clearance_level VARCHAR(32) NOT NULL, -- Level-Supreme, Level-A, Level-B, Level-C, Level-D, Level-Root
    assigned_tasks_count INT DEFAULT 0,
    completed_tasks_count INT DEFAULT 0,
    in_progress_tasks_count INT DEFAULT 0,
    pending_tasks_count INT DEFAULT 0,
    account_status VARCHAR(16) DEFAULT 'ACTIVE', -- ACTIVE, SUSPENDED, OFFLINE, LEAVE
    is_online BOOLEAN DEFAULT FALSE,
    duty_fallback_officer_id VARCHAR(32) REFERENCES staff_users(employee_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==============================================================================
-- 2. جدول السجل الوطني الموحد للمستفيدين (Beneficiary 360 Institutional Registry)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS beneficiaries_registry (
    national_id VARCHAR(32) PRIMARY KEY, -- الرقم الوطني الرسمي (مثل: 01010305468)
    full_name VARCHAR(128) NOT NULL,
    passport_no VARCHAR(32),
    primary_phone VARCHAR(32) NOT NULL,
    alt_phone VARCHAR(32),
    email_address VARCHAR(128),
    residential_address TEXT,
    web3_wallet_address VARCHAR(64),
    kyc_status VARCHAR(32) DEFAULT 'AI_VERIFIED',
    kyc_liveness_score DECIMAL(5, 2) DEFAULT 99.80,
    biometric_face_hash VARCHAR(128),
    is_institution BOOLEAN DEFAULT FALSE,
    institution_commercial_reg VARCHAR(64),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==============================================================================
-- 3. جدول صكوك التوثيق العقاري وتوكزة الأصول (Digital Notary & RWA Deeds)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS notary_deeds (
    deed_id VARCHAR(64) PRIMARY KEY, -- AWD-YE-ADE-TWR-305468
    cadastre_registry_no VARCHAR(64) NOT NULL, -- رقم السجل العقاري
    court_jurisdiction VARCHAR(128) NOT NULL, -- محكمة صيرة وكتابة عدل محافظة عدن
    judicial_record_no VARCHAR(64) NOT NULL, -- 1448/2026/توثيق
    document_type VARCHAR(64) NOT NULL, -- محرر بيع قطعي، تنازل رسمي، رهن عقاري، فرز مشاع
    property_name VARCHAR(128) NOT NULL,
    property_category VARCHAR(32) NOT NULL, -- RESIDENTIAL, COMMERCIAL, INDUSTRIAL, LAND, RWA_FRACTIONAL
    country_code VARCHAR(8) DEFAULT 'YE',
    region_name VARCHAR(64) NOT NULL,
    city_name VARCHAR(64) NOT NULL,
    
    -- المحددات الأربعة التقليدية للمناطق غير المرقومة
    boundary_north TEXT,
    boundary_south TEXT,
    boundary_east TEXT,
    boundary_west TEXT,
    parcel_number VARCHAR(32),
    block_number VARCHAR(32),
    plan_number VARCHAR(32),
    net_area_sqm DECIMAL(12, 2),
    
    -- بيانات التوكزة المالية
    valuation_usd DECIMAL(18, 2) DEFAULT 0.00,
    total_tokens INT DEFAULT 1,
    tokens_purchased INT DEFAULT 1,
    ownership_percentage VARCHAR(16) DEFAULT '100%',
    
    -- أطراف المعاملة
    buyer_national_id VARCHAR(32) REFERENCES beneficiaries_registry(national_id),
    buyer_full_name VARCHAR(128) NOT NULL,
    seller_national_id VARCHAR(32),
    seller_full_name VARCHAR(128),
    
    -- التوقيع الرقمي المزدوج والأمان
    buyer_digital_signature TEXT NOT NULL, -- توقيع وإقرار المشتري (Base64 PNG / ECDSA)
    buyer_auth_code VARCHAR(32) NOT NULL, -- شفرة أمان المشتري AUTH-305468
    buyer_signed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    chief_notary_id VARCHAR(32) REFERENCES staff_users(employee_id),
    chief_notary_signature TEXT NOT NULL, -- توقيع وخاتم كاتب العدل
    notary_auth_code VARCHAR(32) NOT NULL, -- شفرة قلم التوثيق JUD-NOTARY-8849
    notary_attested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    security_hash VARCHAR(128) NOT NULL, -- JUD-SEC-XXXX-XXXX
    hmac_signature VARCHAR(256) NOT NULL, -- HMAC-SHA256 Payload Hash
    official_qr_url TEXT NOT NULL,
    creator_royalty_vault VARCHAR(64) DEFAULT '0x22848f7963Ea954771120d842BD658f12D4Abb43',
    creator_royalty_usd DECIMAL(18, 2) DEFAULT 0.00,
    
    status VARCHAR(32) DEFAULT 'CONFIRMED_EXECUTIVE_TITLE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==============================================================================
-- 4. جدول قيد الدعاوى والتقاضي الإلكتروني والجدولة (E-Litigation Dockets)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS litigation_cases (
    case_id VARCHAR(64) PRIMARY KEY, -- CASE-2026-ADE-4401
    docket_number VARCHAR(64) UNIQUE NOT NULL, -- DOCK-YE-2026-9021
    court_name VARCHAR(128) NOT NULL,
    circuit_name VARCHAR(128) NOT NULL,
    case_type VARCHAR(64) NOT NULL,
    claim_amount_usd DECIMAL(18, 2) DEFAULT 0.00,
    
    session_date DATE NOT NULL,
    session_time TIME NOT NULL,
    virtual_chamber_url TEXT NOT NULL,
    virtual_session_pin VARCHAR(16) NOT NULL,
    
    presiding_judge_id VARCHAR(32) REFERENCES staff_users(employee_id),
    assistant_judges TEXT,
    public_prosecutor_id VARCHAR(32) REFERENCES staff_users(employee_id),
    prosecutor_record_no VARCHAR(64),
    court_clerk_id VARCHAR(32) REFERENCES staff_users(employee_id),
    
    plaintiff_national_id VARCHAR(32) REFERENCES beneficiaries_registry(national_id),
    plaintiff_name VARCHAR(128) NOT NULL,
    plaintiff_attorney_name VARCHAR(128),
    plaintiff_attorney_license VARCHAR(64),
    
    defendant_national_id VARCHAR(32),
    defendant_name VARCHAR(128) NOT NULL,
    defendant_attorney_name VARCHAR(128),
    defendant_attorney_license VARCHAR(64),
    
    expedited_adr_option BOOLEAN DEFAULT FALSE,
    adr_freeze_expiry_date DATE,
    
    ai_stenographer_transcript TEXT,
    ai_contradiction_analysis TEXT,
    case_status VARCHAR(32) DEFAULT 'SCHEDULED_ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==============================================================================
-- 5. جدول قضاء التنفيذ والأوامر القضائية السبعة (Judicial Enforcement Writs)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS enforcement_writs (
    writ_id VARCHAR(64) PRIMARY KEY, -- ENF-YE-2026-8812
    court_jurisdiction VARCHAR(128) NOT NULL,
    enforcement_judge_id VARCHAR(32) REFERENCES staff_users(employee_id),
    order_type VARCHAR(64) NOT NULL,
    
    target_national_id VARCHAR(32) REFERENCES beneficiaries_registry(national_id),
    target_full_name VARCHAR(128) NOT NULL,
    
    token_symbol VARCHAR(16),
    token_units_frozen INT,
    bank_iban VARCHAR(64),
    bank_name VARCHAR(128),
    iso20022_message_code VARCHAR(32), -- camt.056, pacs.008
    passport_number VARCHAR(32),
    border_ports_notified TEXT,
    monthly_rental_deduction_pct DECIMAL(5, 2),
    auction_opening_price_usd DECIMAL(18, 2),
    settlement_reference_no VARCHAR(64),
    
    execution_status VARCHAR(32) DEFAULT 'EXECUTED_AUTONOMOUSLY',
    iso_wire_ack_ref VARCHAR(64),
    creator_royalty_usd DECIMAL(18, 2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==============================================================================
-- 6. جدول أوامر الإفراج القضائي والنيابي (Judicial Release & Bail Warrants)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS release_warrants (
    warrant_id VARCHAR(64) PRIMARY KEY, -- REL-YE-2026-7701
    court_or_prosecution_name VARCHAR(128) NOT NULL,
    issuing_authority_id VARCHAR(32) REFERENCES staff_users(employee_id),
    warrant_type VARCHAR(64) NOT NULL,
    
    beneficiary_national_id VARCHAR(32) REFERENCES beneficiaries_registry(national_id),
    beneficiary_full_name VARCHAR(128) NOT NULL,
    detention_facility_name VARCHAR(128) NOT NULL,
    
    bail_amount_usd DECIMAL(18, 2) DEFAULT 0.00,
    bail_escrow_tx_hash VARCHAR(128),
    guarantor_name VARCHAR(128),
    guarantor_national_id VARCHAR(32),
    guarantor_phone VARCHAR(32),
    
    security_dispatch_barcode VARCHAR(64) NOT NULL,
    hmac_security_seal VARCHAR(128) NOT NULL,
    direct_dispatch_status VARCHAR(32) DEFAULT 'DISPATCHED_TO_SECURITY_DIRECTORATE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==============================================================================
-- 7. جدول التراضي والوساطة والتحكيم الدولي (Mediation & ADR Accords)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS mediation_accords (
    accord_id VARCHAR(64) PRIMARY KEY, -- MED-ADR-2026-5510
    convention_framework VARCHAR(64) DEFAULT 'SINGAPORE_CONVENTION_2019',
    center_name VARCHAR(128) NOT NULL,
    certified_mediator_id VARCHAR(32) REFERENCES staff_users(employee_id),
    mediator_name VARCHAR(128) NOT NULL,
    
    first_party_national_id VARCHAR(32) REFERENCES beneficiaries_registry(national_id),
    first_party_name VARCHAR(128) NOT NULL,
    first_party_signature TEXT NOT NULL,
    first_party_auth_code VARCHAR(32) NOT NULL,
    
    second_party_national_id VARCHAR(32) REFERENCES beneficiaries_registry(national_id),
    second_party_name VARCHAR(128) NOT NULL,
    second_party_signature TEXT NOT NULL,
    second_party_auth_code VARCHAR(32) NOT NULL,
    
    arbitrator_seal_code VARCHAR(32) NOT NULL,
    accord_summary TEXT NOT NULL,
    settlement_amount_usd DECIMAL(18, 2) DEFAULT 0.00,
    executive_writ_endorsed BOOLEAN DEFAULT TRUE,
    court_ratification_seal VARCHAR(128) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==============================================================================
-- 8. جدول التركات وقسمة المواريث الشرعية (Estate & Sharia Inheritance)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS estate_divisions (
    estate_id VARCHAR(64) PRIMARY KEY, -- EST-YE-2026-3301
    deceased_national_id VARCHAR(32) NOT NULL,
    deceased_full_name VARCHAR(128) NOT NULL,
    death_certificate_no VARCHAR(64) NOT NULL,
    court_jurisdiction VARCHAR(128) NOT NULL,
    certified_judge_id VARCHAR(32) REFERENCES staff_users(employee_id),
    
    total_estate_valuation_usd DECIMAL(18, 2) NOT NULL,
    charity_bequest_amount_usd DECIMAL(18, 2) DEFAULT 0.00,
    voluntary_gift_hibah_usd DECIMAL(18, 2) DEFAULT 0.00,
    net_distributable_usd DECIMAL(18, 2) NOT NULL,
    
    total_heirs_count INT NOT NULL,
    sharia_calculation_matrix JSON NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS estate_heir_subdeeds (
    subdeed_id VARCHAR(64) PRIMARY KEY,
    estate_id VARCHAR(64) REFERENCES estate_divisions(estate_id),
    heir_national_id VARCHAR(32) REFERENCES beneficiaries_registry(national_id),
    heir_full_name VARCHAR(128) NOT NULL,
    relationship_to_deceased VARCHAR(32) NOT NULL,
    sharia_share_fraction VARCHAR(16) NOT NULL,
    allocated_tokens INT NOT NULL,
    allocated_value_usd DECIMAL(18, 2) NOT NULL,
    derived_deed_code VARCHAR(64) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==============================================================================
-- 9. جدول الأبوستيل والتصديق الدولي (The Hague e-Apostille 1961)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS apostille_certificates (
    apostille_id VARCHAR(64) PRIMARY KEY,
    convention_title VARCHAR(128) DEFAULT 'CONVENTION DE LA HAYE DU 5 OCTOBRE 1961',
    origin_country VARCHAR(64) DEFAULT 'Republic of Yemen',
    issuing_authority VARCHAR(128) DEFAULT 'Ministry of Justice - Sovereign Judicial Mesh',
    acting_official_id VARCHAR(32) REFERENCES staff_users(employee_id),
    acting_official_title VARCHAR(128) NOT NULL,
    
    source_document_type VARCHAR(64) NOT NULL,
    source_document_ref VARCHAR(64) NOT NULL,
    destination_country VARCHAR(64) NOT NULL,
    
    mletr_data_hash VARCHAR(128) NOT NULL,
    rfc3161_trusted_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    international_qr_verify_url TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==============================================================================
-- 10. جدول سجل العمليات التفصيلية وحساب نسب الخزينة (Itemized Operations Ledger)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS judicial_transactions (
    transaction_id VARCHAR(64) PRIMARY KEY,
    operation_type VARCHAR(64) NOT NULL,
    reference_code VARCHAR(64) NOT NULL,
    beneficiary_name VARCHAR(128) NOT NULL,
    beneficiary_national_id VARCHAR(32) REFERENCES beneficiaries_registry(national_id),
    handling_officer_id VARCHAR(32) REFERENCES staff_users(employee_id),
    court_jurisdiction VARCHAR(128) NOT NULL,
    case_category VARCHAR(64),
    
    monetary_amount_usd DECIMAL(18, 2) DEFAULT 0.00,
    creator_royalty_usd DECIMAL(18, 2) DEFAULT 0.00,
    vault_address VARCHAR(64) DEFAULT '0x22848f7963Ea954771120d842BD658f12D4Abb43',
    execution_latency_ms INT DEFAULT 420,
    
    security_hash VARCHAR(128) NOT NULL,
    digital_signature VARCHAR(256) NOT NULL,
    status VARCHAR(32) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==============================================================================
-- 11. جدول الربط التكاملي بين الوزارات والمؤسسات (Cross-Ministerial Sync Hub)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS cross_ministerial_sync (
    sync_id VARCHAR(64) PRIMARY KEY,
    beneficiary_national_id VARCHAR(32) REFERENCES beneficiaries_registry(national_id),
    ministry_code VARCHAR(32) NOT NULL,
    external_record_id VARCHAR(64) NOT NULL,
    record_summary TEXT NOT NULL,
    mTLS_handshake_status VARCHAR(32) DEFAULT 'VERIFIED_TLS_1_3',
    iso20022_message_ref VARCHAR(64),
    sync_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==============================================================================
-- 12. جدول مقسم التوحيد القضائي والربط البيني بين صنعاء وعدن (Sanaa-Aden Dual Mesh Bridge)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS inter_jurisdiction_bridge_ledger (
    bridge_record_id VARCHAR(64) PRIMARY KEY,
    deed_or_case_ref VARCHAR(64) NOT NULL,
    origin_jurisdiction_node VARCHAR(32) NOT NULL, -- YE-ADE (عدن) أو YE-SAN (صنعاء)
    target_jurisdiction_node VARCHAR(32) NOT NULL, -- YE-SAN (صنعاء) أو YE-ADE (عدن)
    beneficiary_national_id VARCHAR(32) REFERENCES beneficiaries_registry(national_id),
    operation_type VARCHAR(64) NOT NULL,
    unified_universal_hash VARCHAR(128) NOT NULL,
    aden_moj_sync_ack VARCHAR(64) DEFAULT 'ACK_CONFIRMED_ADEN_NODE',
    sanaa_moj_sync_ack VARCHAR(64) DEFAULT 'ACK_CONFIRMED_SANAA_NODE',
    anti_duplicate_lock_status VARCHAR(32) DEFAULT 'IMMUTABLY_LOCKED_NATIONWIDE',
    settlement_currency VARCHAR(16) DEFAULT 'DUAL_CURRENCY_ADAPTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_bridge_deed_ref ON inter_jurisdiction_bridge_ledger(deed_or_case_ref);
CREATE INDEX IF NOT EXISTS idx_bridge_beneficiary ON inter_jurisdiction_bridge_ledger(beneficiary_national_id);

-- ==============================================================================
-- 13. جدول سجل المقاصة البنكية والربط مع البنك المركزي (Central Bank ISO 20022 Ledger)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS central_bank_iso20022_ledger (
    iso_message_id VARCHAR(64) PRIMARY KEY,
    message_type VARCHAR(32) NOT NULL, -- pacs.008, camt.056, camt.029
    bank_switch_node VARCHAR(64) NOT NULL,
    origin_account_or_iban VARCHAR(64) NOT NULL,
    target_account_or_iban VARCHAR(64) NOT NULL,
    gross_amount_usd DECIMAL(18, 2) NOT NULL,
    creator_royalty_usd DECIMAL(18, 2) NOT NULL,
    creator_royalty_vault VARCHAR(64) DEFAULT '0x22848f7963Ea954771120d842BD658f12D4Abb43',
    clearance_status VARCHAR(32) DEFAULT 'CLEARED_AND_SETTLED_RTGS',
    central_bank_ack_ref VARCHAR(64) NOT NULL,
    execution_latency_ms INT DEFAULT 280,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_iso_message_type ON central_bank_iso20022_ledger(message_type);

-- ==============================================================================
-- 14. جدول حسابات وصناديق خزانة الدولة والتوريد الآلي الشفاف (State Treasury Funds Ledger)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS state_treasury_funds_ledger (
    disbursement_id VARCHAR(64) PRIMARY KEY,
    transaction_ref VARCHAR(64) NOT NULL,
    operation_type VARCHAR(64) NOT NULL,
    
    central_bank_target VARCHAR(32) NOT NULL, -- CBY_ADEN أو CBY_SANAA
    state_treasury_account_no VARCHAR(64) NOT NULL, -- 01001-001001-CBY-ADE أو 01002-002002-CBY-SAN
    state_treasury_iban VARCHAR(64) NOT NULL,
    dedicated_fund_name VARCHAR(128) NOT NULL,
    
    gross_transaction_usd DECIMAL(18, 2) NOT NULL,
    state_duty_amount_usd DECIMAL(18, 2) NOT NULL,
    creator_wallet_royalty_usd DECIMAL(18, 2) NOT NULL, -- 0.5%
    creator_bank_royalty_usd DECIMAL(18, 2) NOT NULL,   -- 0.5%
    creator_total_royalty_usd DECIMAL(18, 2) NOT NULL,  -- 1.0%
    partner_net_amount_usd DECIMAL(18, 2) NOT NULL,
    creator_wallet_address VARCHAR(64) DEFAULT '0x22848f7963Ea954771120d842BD658f12D4Abb43',
    creator_bank_account_no VARCHAR(64) DEFAULT '01001-DEV-305468-ADE',
    creator_national_id VARCHAR(32) DEFAULT '01010305468',
    
    cby_clearing_ack_ref VARCHAR(64) NOT NULL,
    blockchain_split_tx_hash VARCHAR(128) NOT NULL,
    transparency_audit_hash VARCHAR(128) NOT NULL,
    status VARCHAR(32) DEFAULT 'DISBURSED_AND_CONFIRMED',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_treasury_fund_cby ON state_treasury_funds_ledger(central_bank_target);
CREATE INDEX IF NOT EXISTS idx_treasury_tx_ref ON state_treasury_funds_ledger(transaction_ref);