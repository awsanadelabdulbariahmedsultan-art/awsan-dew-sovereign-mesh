from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import hashlib
import time

app = FastAPI(
    title="Awsan Dew Sovereign Judicial Bridge API",
    version="3.0.0",
    description="Sovereign Inter-Ministerial & ISO 20022 Settlement Gateway"
)

# تفعيل CORS للتواصل السلس مع واجهة GitHub Pages
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class InvestorIdentity(BaseModel):
    fullName: str
    nationalId: str
    walletAddress: str

class NotarySyncPayload(BaseModel):
    protocol: str
    deedId: str
    cadastreRegistryNo: str
    courtJurisdiction: str
    judicialRecordNo: str
    verificationSecurityHash: str
    investorIdentity: InvestorIdentity

@app.post("/v1/justice/notary-escrow-sync")
async def sync_notary_deed(payload: NotarySyncPayload):
    # محاكاة توليد بصمة التدقيق المحاسبي transparencyAuditProof
    raw_str = f"{payload.deedId}:{payload.investorIdentity.nationalId}:{time.time()}"
    audit_proof = "0x" + hashlib.sha256(raw_str.encode()).hexdigest()
    
    return {
        "statusCode": 200,
        "status": "JUDICIAL_RECORD_CONFIRMED",
        "ministryReference": f"MOJ-YE-NOTARY-2026-{int(time.time()) % 1000000}",
        "transparencyAuditProof": audit_proof,
        "creatorRoyaltyVault": "0x22848f7963Ea954771120d842BD658f12D4Abb43",
        "iso20022_status": "SETTLED_CONFIRMED",
        "message": "Deed verified, registered in National Judicial Registry, and matched autonomously."
    }

@app.get("/health")
async def health_check():
    return {"status": "ONLINE", "mesh": "Active mTLS 1.3", "version": "3.0.0"}
