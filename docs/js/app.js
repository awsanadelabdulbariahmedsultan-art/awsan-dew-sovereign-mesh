window.addEventListener('DOMContentLoaded', () => {
    // تفعيل لوحات التوقيع
    ['buyer-canvas', 'notary-canvas', 'med-canvas-1', 'med-canvas-2'].forEach(id => {
        window.SignatureEngine.setupCanvas(id);
    });

    // ملء بيانات الدول
    populateCountries();
});

function populateCountries() {
    const sel = document.getElementById('notary-country-select');
    if (!sel || !window.jurisdictionData) return;
    sel.innerHTML = '';
    Object.keys(window.jurisdictionData).forEach(k => {
        const opt = document.createElement('option');
        opt.value = k;
        opt.innerText = window.jurisdictionData[k].name_ar;
        sel.appendChild(opt);
    });
}

function setMasterHub(hub) {
    const fin = document.getElementById('master-hub-financial-content');
    const jud = document.getElementById('master-hub-judicial-content');
    const rep = document.getElementById('master-hub-reports-content');

    const bFin = document.getElementById('btn-hub-financial');
    const bJud = document.getElementById('btn-hub-judicial');
    const bRep = document.getElementById('btn-hub-reports');

    [fin, jud, rep].forEach(el => { if (el) el.style.display = 'none'; });
    [bFin, bJud, bRep].forEach(el => { if (el) el.classList.remove('active'); });

    if (hub === 'FINANCIAL') {
        fin.style.display = 'block';
        bFin.classList.add('active');
    } else if (hub === 'REPORTS') {
        rep.style.display = 'block';
        bRep.classList.add('active');
    } else {
        jud.style.display = 'block';
        bJud.classList.add('active');
    }
}

function switchTab(tabId) {
    setMasterHub('JUDICIAL');
    document.querySelectorAll('.tab-pane').forEach(p => p.classList.remove('active'));
    document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));

    const target = document.getElementById('tab-' + tabId);
    if (target) target.classList.add('active');
}

function printSection(elementId) {
    const content = document.getElementById(elementId)?.outerHTML;
    const mount = document.getElementById('print-mount-point');
    if (mount && content) {
        mount.innerHTML = `<div dir="rtl">${content}</div>`;
        window.print();
    }
}
// docs/js/app.js

window.addEventListener('DOMContentLoaded', () => {
    initCanvases();
    initLocationDropdowns();
    renderHrStaffTable();
});

// 1. تهيئة لوحات التوقيع الرقمي
function initCanvases() {
    ['buyer-notary-canvas', 'notary-canvas', 'lit-judge-canvas', 'enf-judge-canvas', 'est-judge-canvas', 'apo-canvas', 'med-canvas-1', 'med-canvas-2'].forEach(id => {
        const c = document.getElementById(id);
        if (!c) return;
        const ctx = c.getContext('2d');
        ctx.strokeStyle = "#0f172a";
        ctx.lineWidth = 2.5;
        ctx.lineCap = "round";

        let isDrawing = false;
        const getPos = (e) => {
            const r = c.getBoundingClientRect();
            const cx = e.touches ? e.touches[0].clientX : e.clientX;
            const cy = e.touches ? e.touches[0].clientY : e.clientY;
            return { x: (cx - r.left) * (c.width / r.width), y: (cy - r.top) * (c.height / r.height) };
        };

        c.addEventListener('mousedown', (e) => { isDrawing = true; ctx.beginPath(); const p = getPos(e); ctx.moveTo(p.x, p.y); });
        c.addEventListener('mousemove', (e) => { if (isDrawing) { const p = getPos(e); ctx.lineTo(p.x, p.y); ctx.stroke(); } });
        window.addEventListener('mouseup', () => { isDrawing = false; });

        c.addEventListener('touchstart', (e) => { isDrawing = true; ctx.beginPath(); const p = getPos(e); ctx.moveTo(p.x, p.y); if(e.cancelable) e.preventDefault(); }, { passive: false });
        c.addEventListener('touchmove', (e) => { if (isDrawing) { const p = getPos(e); ctx.lineTo(p.x, p.y); ctx.stroke(); } if(e.cancelable) e.preventDefault(); }, { passive: false });
        window.addEventListener('touchend', () => { isDrawing = false; });
    });
}

function clearSignature(id) {
    const c = document.getElementById(id);
    if (c) c.getContext('2d').clearRect(0, 0, c.width, c.height);
}

function autoSign(id) {
    const c = document.getElementById(id);
    if (!c) return;
    const ctx = c.getContext('2d');
    ctx.clearRect(0, 0, c.width, c.height);
    ctx.font = "italic bold 22px 'Brush Script MT', cursive, sans-serif";
    ctx.fillStyle = "#0284c7";
    ctx.fillText("Official Attestation", 25, 60);
    ctx.beginPath();
    ctx.moveTo(20, 75);
    ctx.bezierCurveTo(80, 95, 180, 50, 320, 80);
    ctx.strokeStyle = "#0284c7";
    ctx.lineWidth = 2.2;
    ctx.stroke();
}

function autoSignBuyer(id) {
    autoSign(id);
}

function triggerBiometricFingerprint(canvasId, name, nid, stampBoxId) {
    autoSign(canvasId);
    if (stampBoxId) {
        const box = document.getElementById(stampBoxId);
        if (box) box.style.display = 'block';
    }
}

// 2. إدارة التبديل بين المراكز (DeFi / Judicial / Reports)
function setMasterHub(hub) {
    const fin = document.getElementById('master-hub-financial-content');
    const jud = document.getElementById('master-hub-judicial-content');
    const rep = document.getElementById('master-hub-reports-content');

    const bFin = document.getElementById('btn-hub-financial');
    const bJud = document.getElementById('btn-hub-judicial');
    const bRep = document.getElementById('btn-hub-reports');

    [fin, jud, rep].forEach(el => { if (el) el.style.display = 'none'; });
    [bFin, bJud, bRep].forEach(el => { if (el) el.classList.remove('active'); });

    if (hub === 'FINANCIAL') {
        if (fin) fin.style.display = 'block';
        if (bFin) bFin.classList.add('active');
    } else if (hub === 'REPORTS') {
        if (rep) rep.style.display = 'block';
        if (bRep) bRep.classList.add('active');
    } else {
        if (jud) jud.style.display = 'block';
        if (bJud) bJud.classList.add('active');
    }
}

// 3. إدارة التبويبات الـ 11
function switchTab(tabId) {
    setMasterHub('JUDICIAL');
    document.querySelectorAll('.tab-pane').forEach(p => p.classList.remove('active'));
    document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));

    const target = document.getElementById('tab-' + tabId);
    if (target) target.classList.add('active');

    const quickSel = document.getElementById('quick-section-selector');
    if (quickSel && quickSel.value !== tabId) quickSel.value = tabId;
}

// 4. تعبئة القوائم الجغرافية من jurisdictions.js
function initLocationDropdowns() {
    const cSel = document.getElementById('notary-country-select');
    if (!cSel || !window.jurisdictionData) return;
    cSel.innerHTML = '';
    Object.keys(window.jurisdictionData).forEach(k => {
        const opt = document.createElement('option');
        opt.value = k;
        opt.innerText = window.jurisdictionData[k].name_ar;
        cSel.appendChild(opt);
    });
    onNotaryCountryChange(cSel.value);
}

function onNotaryCountryChange(countryKey) {
    const pSel = document.getElementById('notary-province-select');
    if (!pSel || !window.jurisdictionData[countryKey]) return;
    pSel.innerHTML = '';
    const provs = window.jurisdictionData[countryKey].provinces || {};
    Object.keys(provs).forEach(p => {
        const opt = document.createElement('option');
        opt.value = p;
        opt.innerText = p;
        pSel.appendChild(opt);
    });
    onNotaryProvinceChange(pSel.value);
}

function onNotaryProvinceChange(provKey) {
    const cSel = document.getElementById('notary-country-select')?.value;
    const courtSel = document.getElementById('notary-court-select');
    if (!courtSel || !cSel || !window.jurisdictionData[cSel]?.provinces[provKey]) return;
    courtSel.innerHTML = '';
    window.jurisdictionData[cSel].provinces[provKey].forEach(court => {
        const opt = document.createElement('option');
        opt.value = court;
        opt.innerText = court;
        courtSel.appendChild(opt);
    });
    updateDeedIdPreview();
}

function updateDeedIdPreview() {
    const c = document.getElementById('notary-country-select')?.value === 'Yemen' ? 'YE' : 'SA';
    const cat = document.getElementById('notary-inv-category')?.value || 'REAL';
    const type = document.getElementById('notary-deed-type')?.value || 'TWR';
    const nid = document.getElementById('notary-owner-nid')?.value || '01010305468';
    const serial = document.getElementById('notary-serial-no')?.value || '0001';
    
    const deedId = `AWD-${c}-${cat}-${type}-${nid}-${serial}`;
    const input = document.getElementById('notary-deed-id');
    if (input) input.value = deedId;
}

function calculateNotaryShare() {
    const val = parseFloat(document.getElementById('notary-val')?.value) || 500000;
    const tokens = parseFloat(document.getElementById('notary-tokens')?.value) || 10;
    const share = ((tokens * 100) / val) * 100;
    const el = document.getElementById('notary-share');
    if (el) el.value = `${share.toFixed(2)}%`;
}

// 5. محرك التوثيق وإصدار الصكوك
function runNotarization() {
    updateDeedIdPreview();
    const deedId = document.getElementById('notary-deed-id')?.value;
    const owner = document.getElementById('notary-owner-name')?.value;
    const nid = document.getElementById('notary-owner-nid')?.value;
    const court = document.getElementById('notary-court-select')?.value;
    const cadastre = document.getElementById('notary-cadastre')?.value;
    const share = document.getElementById('notary-share')?.value;

    document.getElementById('cert-deed-id').innerText = deedId;
    document.getElementById('cert-owner').innerText = owner;
    document.getElementById('cert-nid').innerText = nid;
    document.getElementById('cert-court').innerText = court;
    document.getElementById('cert-cadastre').innerText = cadastre;
    document.getElementById('cert-shares').innerText = share;
    document.getElementById('cert-sec-hash').innerText = "JUD-SEC-" + Math.random().toString(36).substring(2, 10).toUpperCase();

    // نقل التواقيع الحية إلى وثيقة الصك
    syncCanvasToImg('buyer-notary-canvas', 'cert-buyer-sig-img', 'cert-buyer-sig-placeholder');
    syncCanvasToImg('notary-canvas', 'cert-notary-sig-img', 'cert-notary-sig-placeholder');

    document.getElementById('cert-audit-proof').innerText = "0x" + Array.from(crypto.getRandomValues(new Uint8Array(24))).map(b => b.toString(16).padStart(2,'0')).join('');
    document.getElementById('notary-result')?.classList.add('active');
}

function syncCanvasToImg(canvasId, imgId, placeholderId) {
    const c = document.getElementById(canvasId);
    const img = document.getElementById(imgId);
    if (!c || !img) return;
    img.src = c.toDataURL("image/png");
    img.style.display = "inline-block";
    const ph = document.getElementById(placeholderId);
    if (ph) ph.style.display = "none";
}

// 6. الطباعة الرسمية
function printDeedCertificate() {
    runNotarization();
    const cert = document.getElementById('printable-deed')?.outerHTML;
    const mount = document.getElementById('print-mount-point');
    if (mount && cert) {
        mount.innerHTML = `<div dir="rtl">${cert}</div>`;
        window.print();
    }
}

// 7. إدارة الجلسات والمودالات
function openLoginModal() { document.getElementById('login-modal')?.classList.add('active'); }
function closeLoginModal() { document.getElementById('login-modal')?.classList.remove('active'); }
function closeChamberModal() { document.getElementById('chamber-modal')?.classList.remove('active'); }
function launchVirtualChamber() { document.getElementById('chamber-modal')?.classList.add('active'); }

function renderHrStaffTable() {
    const tbody = document.getElementById('hr-staff-table-body');
    if (!tbody || !window.officialStaffRoster) return;
    tbody.innerHTML = '';
    window.officialStaffRoster.forEach(s => {
        tbody.innerHTML += `
            <tr>
                <td style="color:var(--gold); font-family:monospace; font-weight:bold;">${s.code}</td>
                <td><strong>${s.name}</strong><br><small style="color:#94a3b8;">${s.role}</small></td>
                <td>${s.court}</td>
                <td>المقر الرئيسي</td>
                <td>45</td>
                <td style="color:#34d399;">43</td>
                <td>2</td>
                <td>0</td>
                <td>${s.status}</td>
                <td><button type="button" class="btn-secondary" style="padding:4px 8px; font-size:0.75rem;" onclick="alert('سجل الموظف: ${s.name}')">عرض</button></td>
            </tr>
        `;
    });
}
