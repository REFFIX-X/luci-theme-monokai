/* SPA navigation does not fire beforeunload, so a half-edited CBI form would be discarded on a
 * menu click. fieldDirty() is the check; leaveBlocked() arms for one activation and allows the next. */
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { loadModule, fakeL, fakeWindow, fakeDocument } from './lib/luci-module.mjs';

function router(document) {
	const win = fakeWindow();
	const doc = document || fakeDocument();
	globalThis._ = (s) => s;
	return loadModule('fs-router', {
		L: fakeL(), window: win, document: doc,
		stubs: {
			ui: { hideModal() {} },
			rpc: { addInterceptor() {} },
			'fs-menutree': { segsFromPath: () => null, currentNode: () => null,
				resolveSegs: () => null, viewClassFor: () => null, tree: () => null },
			'fs-sheets': { documentPoisoned: () => false },
			'fs-chrome': { renderChrome() {} },
			'fs-fit': { forgetRest() {}, schedule() {} }
		}
	});
}

function text(value, defaultValue, extra = {}) {
	return { nodeName: 'INPUT', type: 'text', value, defaultValue, disabled: false, ...extra };
}

test('fieldDirty sees edited text, checks and selects, and ignores buttons', () => {
	const mod = router();
	assert.equal(mod.fieldDirty(text('a', 'a')), false);
	assert.equal(mod.fieldDirty(text('b', 'a')), true);
	assert.equal(mod.fieldDirty(text('b', 'a', { disabled: true })), false);
	assert.equal(mod.fieldDirty({ nodeName: 'INPUT', type: 'submit', value: 'Save', defaultValue: '', disabled: false }), false);
	assert.equal(mod.fieldDirty({ nodeName: 'INPUT', type: 'checkbox', checked: true, defaultChecked: false, disabled: false }), true);
	assert.equal(mod.fieldDirty({ nodeName: 'INPUT', type: 'checkbox', checked: false, defaultChecked: false, disabled: false }), false);
	assert.equal(mod.fieldDirty({ nodeName: 'TEXTAREA', value: 'x', defaultValue: '' }), true);
	assert.equal(mod.fieldDirty({ nodeName: 'SELECT', options: [ { selected: true, defaultSelected: true } ] }), false);
	assert.equal(mod.fieldDirty({ nodeName: 'SELECT', options: [ { selected: false, defaultSelected: true } ] }), true);
	assert.equal(mod.fieldDirty(null), false);
});

test('leaveBlocked announces once, then allows the next activation', () => {
	const live = { textContent: '' };
	const view = { querySelectorAll: () => [ text('edited', '') ] };
	const doc = fakeDocument({
		getElementById(id) {
			if (id === 'view') return view;
			if (id === 'fs-nav-status') return live;
			return null;
		}
	});
	const mod = router(doc);
	assert.equal(mod.leaveBlocked(), true);
	assert.match(live.textContent, /Unsaved changes/);
	assert.equal(mod.leaveBlocked(), false, 'the second activation inside the window proceeds');
});

test('a clean view does not arm the guard', () => {
	const doc = fakeDocument({
		getElementById(id) { return id === 'view' ? { querySelectorAll: () => [] } : null; }
	});
	const mod = router(doc);
	assert.equal(mod.leaveBlocked(), false);
	assert.equal(mod.leaveBlocked(), false);
});
