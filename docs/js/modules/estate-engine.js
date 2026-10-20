window.EstateEngine = {
    calculateNet() {
        const total = parseFloat(document.getElementById('est-total')?.value) || 0;
        const debts = parseFloat(document.getElementById('est-debts')?.value) || 0;
        const will = parseFloat(document.getElementById('est-will')?.value) || 0;
        const gift = parseFloat(document.getElementById('est-gift')?.value) || 0;
        
        const net = Math.max(0, total - debts - will - gift);
        const netInput = document.getElementById('est-net');
        if (netInput) netInput.value = `$${net.toLocaleString()}`;
        return net;
    },

    divide() {
        const net = this.calculateNet();
        const sons = parseInt(document.getElementById('est-sons')?.value) || 0;
        const daughters = parseInt(document.getElementById('est-daughters')?.value) || 0;

        const wifeShare = net * 0.125;
        const rem = net - wifeShare;
        const parts = (sons * 2) + daughters;
        const partVal = parts > 0 ? (rem / parts) : 0;

        const breakdown = document.getElementById('est-breakdown');
        if (breakdown) {
            breakdown.innerHTML = `
                <div class="cert-row"><span>صافي التركة المحسوبة:</span><strong style="color:var(--emerald);">$${net.toLocaleString()} USD</strong></div>
                <div class="cert-row"><span>نصيب الزوجة (الثمن فرضا):</span><strong>$${wifeShare.toLocaleString()} USD</strong></div>
                <div class="cert-row"><span>نصيب كل ابن (سهمان):</span><strong>$${(partVal * 2).toFixed(2)} USD</strong></div>
                <div class="cert-row"><span>نصيب كل بنت (سهم واحد):</span><strong>$${partVal.toFixed(2)} USD</strong></div>
            `;
        }
        document.getElementById('est-result')?.classList.add('active');
    }
};
