const root = document.getElementById('notify-root');
const DEFAULT_DURATION = 4500;
let maxVisible = 3;
let queueEnabled = true;
let soundEnabled = true;
let soundVolume = 0.34;
let soundPack = 'premium';
let showWatermark = true;
const queue = [];
const active = new Map();

const iconMap = {
    success: 'icons/success.png',
    error: 'icons/error.png',
    danger: 'icons/error.png',
    warning: 'icons/warning.png',
    warn: 'icons/warning.png',
    info: 'icons/info.png',
    inform: 'icons/info.png',
    primary: 'icons/info.png',
    money: 'icons/money.png',
    bank: 'icons/bank.png',
    cash: 'icons/money.png',
    police: 'icons/police.png',
    ems: 'icons/ems.png',
    mechanic: 'icons/mechanic.png',
    vip: 'icons/vip.png',
    premium: 'icons/vip.png',
    server: 'icons/server.png',
    announce: 'icons/server.png',
    illegal: 'icons/illegal.png'
};

const titleMap = {
    success: 'SIKERES',
    error: 'HIBA',
    danger: 'HIBA',
    warning: 'FIGYELMEZTETÉS',
    warn: 'FIGYELMEZTETÉS',
    info: 'INFORMÁCIÓ',
    inform: 'INFORMÁCIÓ',
    primary: 'INFORMÁCIÓ',
    money: 'PÉNZÜGY',
    bank: 'BANK',
    cash: 'PÉNZÜGY',
    police: 'RENDŐRSÉG',
    ems: 'MENTŐSZOLGÁLAT',
    mechanic: 'SZERELŐ',
    vip: 'VIP',
    premium: 'PRÉMIUM',
    server: 'REALRPG',
    announce: 'KÖZLEMÉNY',
    illegal: 'FIGYELEM'
};

const soundFiles = {
    success: 'sounds/success.wav',
    info: 'sounds/info.wav',
    warning: 'sounds/warning.wav',
    error: 'sounds/error.wav',
    money: 'sounds/money.wav',
    bank: 'sounds/bank.wav',
    police: 'sounds/police.wav',
    ems: 'sounds/ems.wav',
    mechanic: 'sounds/mechanic.wav',
    vip: 'sounds/vip.wav',
    server: 'sounds/server.wav',
    announce: 'sounds/server.wav',
    illegal: 'sounds/illegal.wav'
};

function sanitize(value) {
    return String(value ?? '')
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#039;');
}

function normalizeType(type) {
    type = String(type || 'info').toLowerCase();
    if (type === 'inform' || type === 'primary' || type === 'notification' || type === 'normal') return 'info';
    if (type === 'warn') return 'warning';
    if (type === 'danger') return 'error';
    if (type === 'cash' || type === 'pay') return 'money';
    if (type === 'lspd' || type === 'policejob') return 'police';
    if (type === 'ambulance' || type === 'doctor' || type === 'emsjob') return 'ems';
    if (type === 'mech' || type === 'mechanicjob') return 'mechanic';
    if (type === 'premium') return 'vip';
    if (type === 'admin' || type === 'system') return 'server';
    if (type === 'announcement') return 'announce';
    if (!iconMap[type]) return 'info';
    return type;
}

function playNotifySound(type, data) {
    const enabled = data.sound;
    if (enabled === false || enabled === 'false') return;
    if (!soundEnabled) return;

    const soundType = normalizeType(type);
    const src = soundFiles[soundType] || soundFiles.info;

    try {
        const audio = new Audio(src);
        let volume = Number(data.soundVolume ?? soundVolume);
        if (soundPack === 'minimal') volume *= 0.55;
        if (soundPack === 'soft') volume *= 0.78;
        audio.volume = Math.max(0, Math.min(1, volume));
        audio.play().catch(() => {});
    } catch (e) {}
}

function setPosition(position) {
    const value = String(position || 'top-center');
    root.className = value;
}

function enqueue(data) {
    maxVisible = Number(data.maxVisible || maxVisible || 3);
    queueEnabled = data.queue === undefined ? queueEnabled : Boolean(data.queue);
    soundEnabled = data.sound === undefined ? soundEnabled : Boolean(data.sound);
    soundVolume = Number(data.soundVolume ?? soundVolume ?? 0.34);
    soundPack = String(data.soundPack || soundPack || 'premium');
    showWatermark = data.showWatermark === undefined ? showWatermark : Boolean(data.showWatermark);
    setPosition(data.position);

    if (!queueEnabled && active.size >= maxVisible) {
        const first = active.keys().next().value;
        const item = active.get(first);
        if (item) item.removeNow?.();
    }

    queue.push(data);
    processQueue();
}

function processQueue() {
    while (active.size < maxVisible && queue.length > 0) {
        showNotify(queue.shift());
    }
}

function showNotify(data) {
    const id = data.id || Date.now() + Math.random();
    const type = normalizeType(data.type);
    const duration = Math.max(1200, Number(data.duration || DEFAULT_DURATION));
    
    // Debug logging
    console.log('[NOTIFY DEBUG] Incoming notification:', {
        original_type: data.type,
        normalized_type: type,
        title_from_data: data.title,
        title_from_map: titleMap[type],
        message: data.message,
        full_data: data
    });
    
    const title = sanitize(data.title || titleMap[type] || 'INFORMÁCIÓ');
    const message = sanitize(data.message || '');
    const icon = iconMap[type] || iconMap.info;

    playNotifySound(type, data);

    const notify = document.createElement('div');
    notify.className = `notify ${type}`;
    notify.innerHTML = `
        <div class="shine"></div>
        <img class="notify-icon" src="${icon}" draggable="false" />
        <div class="notify-content">
            <div class="notify-title">${title}</div>
            <div class="notify-message">${message}</div>
        </div>
        ${showWatermark ? '<div class="brand">RR</div>' : ''}
        <div class="progress-track">
            <div class="progress-bar" style="animation-duration:${duration}ms"></div>
        </div>
    `;

    root.appendChild(notify);
    active.set(id, notify);

    const remove = () => {
        if (!active.has(id)) return;
        notify.classList.add('hide');
        setTimeout(() => {
            notify.remove();
            active.delete(id);
            processQueue();
        }, 420);
    };

    notify.removeNow = remove;
    setTimeout(remove, duration);
}

window.addEventListener('message', (event) => {
    const data = event.data || {};
    if (data.action === 'notify') enqueue(data);
});
