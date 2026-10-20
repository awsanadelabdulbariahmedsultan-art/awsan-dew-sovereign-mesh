window.NotaryEngine = {
    updateDeedId() {
        const c = document.getElementById('notary-country-select')?.value || 'YE';
        const p = document.getElementById('notary-province-select')?.value || 'ADE';
        const t = document.getElementById('notary-deed-type')?.value || 'TWR';
        const nid = document.getElementById('notary-owner-nid')?.value || '01010305468';
        const serial = document.getElementById('notary-serial-no')?.value || '001';
        
        const deedInput = document.getElementById('notary-deed-id');
        if (deedInput) {
            deedInput.value = `AWD-${c}-${p}-${t}-${nid}-${serial}`;
        }
    },

    calculateShare() {
        const val = parseFloat(document.getElementById('notary-val')?.value) || 500000;
        const tokens = parseFloat(document.getElementById('notary-tokens')?.value) || 10;
        const share = ((tokens * 100) / val) * 100;
        const shareInput = document.getElementById('notary-share');
        if (shareInput) shareInput.value = `${share.toFixed(2)}%`;
    },

    runAttestation() {
        this.updateDeedId();
        const deedId = document.getElementById('notary-deed-id')?.value;
        const owner = document.getElementById('notary-owner-name')?.value;
        const nid = document.getElementById('notary-owner-nid')?.value;
        const court = document.getElementById('notary-court-select')?.value;
        const cadastre = document.getElementById('notary-cadastre')?.value;

        document.getElementById('cert-deed-id').innerText = deedId;
        document.getElementById('cert-owner').innerText = owner;
        document.getElementById('cert-nid').innerText = nid;
        document.getElementById('cert-court').innerText = court;
        document.getElementById('cert-cadastre').innerText = cadastre;

        // مزامنة التواقيع في وثيقة الصك
        window.SignatureEngine.syncToImage('buyer-canvas', 'cert-buyer-sig-img', 'cert-buyer-sig-empty');
        window.SignatureEngine.syncToImage('notary-canvas', 'cert-notary-sig-img', 'cert-notary-sig-empty');

        const auditProof = "0x" + Array.from(crypto.getRandomValues(new Uint8Array(24))).map(b => b.toString(16).padStart(2,'0')).join('');
        document.getElementById('cert-audit-proof').innerText = auditProof;

        document.getElementById('notary-result')?.classList.add('active');
    }
};
