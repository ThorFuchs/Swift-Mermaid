// Called with arguments only (callAsyncJavaScript); the diagram source is never part of the script.
let counter = 0;
window.renderMermaid = async function (source, theme, fontFamily) {
  const box = document.getElementById('box');
  box.textContent = '';
  mermaid.initialize({
    startOnLoad: false,
    securityLevel: 'strict',
    theme: theme,
    themeVariables: { background: 'transparent', fontFamily: fontFamily },
    fontFamily: fontFamily,
    deterministicIds: true,
    deterministicIDSeed: 'swift-mermaid',
    maxTextSize: 50000,
    maxEdges: 2000,
  });
  const id = 'swift-mermaid-' + (++counter);
  try {
    await mermaid.parse(source);
    const { svg } = await mermaid.render(id, source);
    box.innerHTML = svg;
  } catch (e) {
    document.querySelectorAll('[id^="d' + id + '"], #' + id).forEach(function (n) { n.remove(); });
    return { error: String(e && e.message ? e.message : e) };
  }
  const el = box.querySelector('svg');
  if (!el) { return { error: 'no diagram produced' }; }
  const vb = el.viewBox && el.viewBox.baseVal;
  if (vb && vb.width > 0 && vb.height > 0) {
    el.setAttribute('width', String(Math.ceil(vb.width)));
    el.setAttribute('height', String(Math.ceil(vb.height)));
    el.style.maxWidth = 'none';
  }
  await document.fonts.ready;
  const r = el.getBoundingClientRect();
  return { x: r.left, y: r.top, width: Math.ceil(r.width), height: Math.ceil(r.height),
           svg: new XMLSerializer().serializeToString(el) };
};
