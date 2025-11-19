// script.js
// Minimal, robust NUI client for la_peditor
(function () {
  'use strict';

  // DOM
  const elPanel = document.getElementById('panel');
  const elLog = document.getElementById('log');
  const btnPing = document.getElementById('btnPing');
  const btnHide = document.getElementById('btnHide');
  const btnClose = document.getElementById('btnClose');
  const elAssetPanel = document.getElementById('assetsPanel');
  const elAssetList = document.getElementById('assetList');

  // Safe logger (appends to the in-panel log and console)
  function escapeHtml(s) {
    return (s+'').replace(/[&<>"']/g, c => ({"&":"&amp;","<":"&lt;",">":"&gt;","\"":"&quot;","'":"&#39;"}[c]));
  }
  function log(msg) {
    try {
      const time = new Date().toLocaleTimeString();
      if (elLog) {
        elLog.innerHTML += `<div>🕰 ${time} — ${escapeHtml(String(msg))}</div>`;
        elLog.scrollTop = elLog.scrollHeight;
      }
    } catch (e) { /* ignore */ }
    console.log('[la_peditor NUI]', msg);
  }

  // Utility: resolve parent resource name in preview or real NUI
  function GetParentResourceName() {
    // Many dev previews set window.parentResource; also support FiveM-provided GetParentResourceName if present.
    try {
      if (typeof window.GetParentResourceName === 'function') return window.GetParentResourceName();
      if (window.parentResource) return window.parentResource;
      if (typeof globalThis !== 'undefined' && globalThis.parentResource) return globalThis.parentResource;
    } catch (e) { /* ignore */ }
    return 'la_peditor';
  }

  // Post to parent (FiveM NUI endpoint). Use consistent endpoint names: 'nuiPing' and 'nuiHide'
  function postToParent(path, payload) {
    const resource = GetParentResourceName();
    const url = `https://${resource}/${path}`;
    return fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json; charset=UTF-8' },
      body: JSON.stringify(payload || {})
    })
    .then(response => {
      // Some preview environments may not behave like FiveM; we catch errors later
      log(`POST ${path} -> ${response.status}`);
      return response.text();
    })
    .catch(err => {
      log(`POST ${path} failed (preview or no host): ${err}`);
      // Rethrow if caller expects it, but many preview callers just ignore
      throw err;
    });
  }

  // Show/hide
  function show(payload) {
    if (elPanel) {
      elPanel.classList.remove('hidden');
      elPanel.setAttribute('aria-hidden','false');
      log('la_peditor NUI shown — theme="1950s-cartoon-noir"');
      if (payload && payload.message) log('payload: ' + payload.message);
    }
  }
  function hide() {
    if (elPanel) {
      elPanel.classList.add('hidden');
      elPanel.setAttribute('aria-hidden','true');
      log('la_peditor NUI hidden — theme="1950s-cartoon-noir"');
    }
    if (elAssetPanel) {
      elAssetPanel.classList.add('hidden');
      if (elAssetList) elAssetList.innerHTML = '';
    }
  }

  function renderAssets(payload) {
    if (!elAssetPanel || !elAssetList) return;
    if (!payload) {
      elAssetPanel.classList.add('hidden');
      elAssetList.innerHTML = '';
      return;
    }
    const packs = Array.isArray(payload.packs) ? payload.packs : [];
    const categories = Array.isArray(payload.categories) ? payload.categories : [];
    let html = '';
    if (packs.length) {
      html += '<div><strong>Packs</strong></div><ul>';
      packs.forEach(pack => {
        const counts = pack.counts || {};
        html += `<li>${escapeHtml(pack.name || pack.id)} <small>(props:${counts.props || 0}, components:${counts.components || 0}, hair:${counts.hair || 0}, beards:${counts.beards || 0})</small></li>`;
      });
      html += '</ul>';
    } else {
      html += '<div>No asset packs loaded.</div>';
    }
    if (categories.length) {
      html += '<div style="margin-top:6px;"><strong>Categories</strong></div><ul>';
      categories.forEach(cat => {
        html += `<li>${escapeHtml(cat.category || 'unknown')}: ${cat.count || 0}</li>`;
      });
      html += '</ul>';
    }
    elAssetList.innerHTML = html;
    elAssetPanel.classList.remove('hidden');
    elAssetPanel.setAttribute('aria-hidden','false');
  }

  // Wire buttons (defensive checks)
  if (btnPing) {
    btnPing.addEventListener('click', () => {
      try {
        postToParent('nuiPing', { message: 'hello from la_peditor NUI', theme: '1950s-cartoon-noir' })
          .then(()=> log('Ping sent to client — theme="1950s-cartoon-noir"'))
          .catch(() => log('Ping (preview mode)'));
      } catch (e) {
        log('Ping error: ' + e);
      }
    });
  }

  if (btnHide) {
    btnHide.addEventListener('click', () => {
      hide();
      // Tell the client to remove focus / close
      postToParent('nuiHide', { theme: '1950s-cartoon-noir' }).catch(()=>{ log('nuiHide (preview)'); });
    });
  }

  if (btnClose) {
    btnClose.addEventListener('click', () => {
      hide();
      postToParent('nuiHide', { theme: '1950s-cartoon-noir' }).catch(()=>{ log('nuiHide (preview)'); });
    });
  }

  // Listen for game/client messages via postMessage (SendNUIMessage -> window.postMessage in many setups)
  window.addEventListener('message', (ev) => {
    try {
      const data = ev.data || {};
      if (!data || !data.type) return;
      switch (data.type) {
        case 'appearance_display':
          show(data.payload || {});
          break;
        case 'appearance_hide':
          hide();
          break;
        case 'appearance_log':
          log(data.payload?.message || 'log');
          break;
        case 'appearance_assets':
          renderAssets(data.payload);
          break;
        default:
          log('Unknown message: ' + String(data.type));
      }
    } catch (e) {
      console.error(e);
    }
  }, false);

  // Start hidden (do NOT auto-open)
  hide();

  // announce ready for client-side checks & preview
  log('la_peditor NUI script loaded — theme="1950s-cartoon-noir"');
  try {
    // Some client scripts may listen for this message to detect readiness
    window.dispatchEvent(new MessageEvent('message', { data: { type: 'nui_ready', payload: { theme: '1950s-cartoon-noir' } } }));
  } catch (e) { /* ignore */ }

  // Expose small API for debugging in preview
  window.laPeditor = { show, hide, log };

})();
