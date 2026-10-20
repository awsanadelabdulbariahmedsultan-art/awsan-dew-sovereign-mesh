window.SignatureEngine = {
    setupCanvas(canvasId) {
        const canvas = document.getElementById(canvasId);
        if (!canvas) return;
        const ctx = canvas.getContext('2d');
        ctx.strokeStyle = "#0f172a";
        ctx.lineWidth = 2.5;
        ctx.lineCap = "round";

        let isDrawing = false;
        const getPos = (e) => {
            const rect = canvas.getBoundingClientRect();
            const clientX = e.touches ? e.touches[0].clientX : e.clientX;
            const clientY = e.touches ? e.touches[0].clientY : e.clientY;
            return {
                x: (clientX - rect.left) * (canvas.width / rect.width),
                y: (clientY - rect.top) * (canvas.height / rect.height)
            };
        };

        canvas.addEventListener('mousedown', (e) => { isDrawing = true; ctx.beginPath(); const p = getPos(e); ctx.moveTo(p.x, p.y); });
        canvas.addEventListener('mousemove', (e) => { if (isDrawing) { const p = getPos(e); ctx.lineTo(p.x, p.y); ctx.stroke(); } });
        window.addEventListener('mouseup', () => { isDrawing = false; });

        canvas.addEventListener('touchstart', (e) => { isDrawing = true; ctx.beginPath(); const p = getPos(e); ctx.moveTo(p.x, p.y); if (e.cancelable) e.preventDefault(); }, { passive: false });
        canvas.addEventListener('touchmove', (e) => { if (isDrawing) { const p = getPos(e); ctx.lineTo(p.x, p.y); ctx.stroke(); if (e.cancelable) e.preventDefault(); } }, { passive: false });
        window.addEventListener('touchend', () => { isDrawing = false; });
    },

    clear(canvasId) {
        const canvas = document.getElementById(canvasId);
        if (canvas) canvas.getContext('2d').clearRect(0, 0, canvas.width, canvas.height);
    },

    autoSign(canvasId, name, hexColor = "#0284c7") {
        const canvas = document.getElementById(canvasId);
        if (!canvas) return;
        const ctx = canvas.getContext('2d');
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        ctx.font = "italic bold 20px 'Brush Script MT', cursive, sans-serif";
        ctx.fillStyle = hexColor;
        ctx.fillText(name, 25, 60);

        ctx.beginPath();
        ctx.moveTo(20, 75);
        ctx.bezierCurveTo(80, 95, 160, 50, 320, 80);
        ctx.strokeStyle = hexColor;
        ctx.lineWidth = 2.2;
        ctx.stroke();

        ctx.font = "bold 9px monospace";
        ctx.fillStyle = "#334155";
        ctx.fillText("VERIFIED ON-SCREEN • " + new Date().toISOString().substring(0, 19).replace('T', ' '), 25, 115);
    },

    syncToImage(canvasId, imgId, placeholderId) {
        const canvas = document.getElementById(canvasId);
        const img = document.getElementById(imgId);
        if (!canvas || !img) return;
        img.src = canvas.toDataURL("image/png");
        img.style.display = "inline-block";
        if (placeholderId) {
            const ph = document.getElementById(placeholderId);
            if (ph) ph.style.display = "none";
        }
    }
};
