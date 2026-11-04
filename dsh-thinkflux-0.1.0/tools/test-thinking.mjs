/**
 * Standalone check for the reasoning channel (no browser, no DSH host).
 * Fake eventSource feeds reasoning-delta frames; asserts the thought queue,
 * recent text, char rate and the anti-double-count rule.
 */
import fs from 'node:fs';
import path from 'node:path';
import vm from 'node:vm';
import { fileURLToPath } from 'node:url';

const root = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
const src = fs.readFileSync(path.join(root, 'src/live.js'), 'utf8');

const listeners = new Set();
const entries = [];
let pending = [];
const source = {
  getSnapshot: () => {
    const change = pending.length ? { kind: 'append', entries: pending.slice() } : undefined;
    pending = [];
    return { entries: entries.slice(), revision: entries.length, change };
  },
  subscribe: (fn) => { listeners.add(fn); return () => listeners.delete(fn); },
};
const binding = { sessionId: 's1', eventSource: source, session: null, ctx: null };

const context = { Date, Math, isFinite, Array, String, Number, Map, Set, Infinity,
  setInterval, clearInterval, setTimeout, clearTimeout, console };
context.window = context;
vm.createContext(context);
vm.runInContext(src + '\n;globalThis.createThinkfluxLive = createThinkfluxLive;', context);
const live = context.createThinkfluxLive({ getSessionId: () => 's1', bindingOf: () => binding });

function push(text, seq, attempt = 'a1') {
  const entry = {
    type: 'transient',
    event: {
      type: 'assistant/live-chunk', seq,
      data: { attemptId: attempt, turn: 1, step: 2, chunk: { type: 'reasoning-delta', index: 0, text } },
    },
  };
  entries.push(entry);
  pending.push(entry);
  for (const fn of listeners) fn();
}

const text = '用户想要一个实时思考可视化。我需要先确认 reasoning-delta 是否在直播事件流里，然后把它接到圆环上。Let me verify the contract first.';
// feed in small chunks like the real stream
for (let i = 0, seq = 1; i < text.length; i += 3, seq++) push(text.slice(i, i + 3), seq);

const pulled = live.pullThoughts(4);
const checks = {
  thinkingChars: live.thinkingChars === text.length,
  thinkingTrue: live.thinking === true,
  queueHasPhrases: pulled.length === 4 && pulled.every((s) => s.length > 0),
  recentTextHasTail: live.recentThoughtText.includes(text.slice(-6)),
  ratePositive: live.thinkingRate > 0,
  noAnswerTokens: live.totalTokens === 0,
};

// durable settlement must not double count anything
entries.push({ type: 'event', event: { type: 'assistant/message', seq: 900, data: { turn: 1, step: 2, message: { role: 'assistant', content: [{ type: 'reasoning', text }, { type: 'text', text: 'done' }] }, usage: { inputTokens: 12, outputTokens: 34, totalTokens: 46 } } } });
pending.push(entries[entries.length - 1]);
for (const fn of listeners) fn();
checks.noDoubleCount = live.thinkingChars === text.length && live.totalTokens === 0;
checks.toolGuard = Array.isArray(live.tools);

// flush tail on finish
const before = live.thinkingChars;
entries.push({ type: 'transient', event: { type: 'assistant/live-chunk', seq: 1000, data: { attemptId: 'a1', chunk: { type: 'finish', reason: 'stop' } } } });
pending.push(entries[entries.length - 1]);
for (const fn of listeners) fn();
checks.finishFlushNoCount = live.thinkingChars === before;

console.log(JSON.stringify({ checks, pulled, recent: live.recentThoughtText, rate: live.thinkingRate }, null, 2));
const failed = Object.entries(checks).filter(([, v]) => !v);
live.dispose();
if (failed.length) { console.error('FAILED: ' + failed.map(([k]) => k).join(', ')); process.exit(1); }
console.log('THINKING CHANNEL OK');
