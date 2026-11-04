/**
 * Smoke-check the built client bundle without a browser: the module loader
 * factory must return the plugin and apply() must register both slots.
 */
import fs from 'node:fs';
import path from 'node:path';
import vm from 'node:vm';
import { fileURLToPath } from 'node:url';

const root = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
const code = fs.readFileSync(path.join(root, 'client.js'), 'utf8');

let factory = null;
const registrations = [];
const locals = [];
const React = {
  createElement: (type, props, ...children) => ({ type, props, children }),
  useState: (v) => [typeof v === 'function' ? v() : v, () => {}],
  useEffect: () => {},
  useRef: (v) => ({ current: v }),
  useCallback: (fn) => fn,
  useMemo: (fn) => fn(),
  useSyncExternalStore: (sub, get) => get(),
  memo: (c) => c,
};
const window = {
  __ModuleLoader__: { load: (def) => { factory = def.factory; } },
  localStorage: { getItem: () => null, setItem: () => {} },
  matchMedia: () => ({ matches: false }),
  addEventListener: () => {},
  removeEventListener: () => {},
  devicePixelRatio: 1,
  location: { href: 'http://127.0.0.1/' },
};
const ctx = {
  get(name) {
    if (name === 'locale') return { register: (ns, id, dict) => locals.push([ns, id, Object.keys(dict).length]) };
    return undefined;
  },
  slots: {
    inject(name, fn) { return fn(); },
    register(def, component) { registrations.push({ name: def.name, id: def.id, component: typeof component }); },
  },
};
const sandbox = { window, document: { documentElement: {} }, navigator: { language: 'zh-CN' }, console, Date, Math, React, setTimeout, clearTimeout };
sandbox.globalThis = sandbox;
vm.createContext(sandbox);
vm.runInContext(code, sandbox);
if (!factory) throw new Error('factory not registered');
const plugin = factory((name) => {
  if (name === 'react') return React;
  throw new Error('unexpected require: ' + name);
});
plugin.apply(ctx);
console.log(JSON.stringify({ registrations, locals, inject: plugin.inject }, null, 2));
if (registrations.length !== 2) { console.error('FAILED: slots'); process.exit(1); }
if (!registrations.every((r) => r.id === 'thinkflux')) { console.error('FAILED: id'); process.exit(1); }
if (!locals.length) { console.error('FAILED: locale'); process.exit(1); }
console.log('CLIENT BUNDLE OK');
