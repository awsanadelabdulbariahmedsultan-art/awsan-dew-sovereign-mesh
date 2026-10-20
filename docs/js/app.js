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
