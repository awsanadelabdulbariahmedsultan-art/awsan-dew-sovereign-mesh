window.JudicialAudioEngine = {
    toggleRecording() {
        const btn = document.getElementById('btn-record-voice');
        if (!btn) return;
        btn.innerHTML = `<i class="fas fa-circle" style="color:red;"></i> جارٍ التسجيل الصوتي...`;
    },

    loadSampleAudio() {
        const player = document.getElementById('audio-player-container');
        if (player) player.style.display = 'block';
        const steno = document.getElementById('stenographer-box');
        if (steno) {
            steno.style.display = 'block';
            document.getElementById('stenographer-text').innerHTML = `
                <p><strong>[00:03] القاضي:</strong> افتتحت الجلسة للنظر في الدعوى رقم AWD-2026.</p>
                <p><strong>[00:15] المدعي:</strong> نطلب إلزام الطرف الثاني بتسليم صكوك الحصص المشاعة RWA.</p>
            `;
        }
    }
};
