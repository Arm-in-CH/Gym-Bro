const fs = require('fs');
const vm = require('node:vm');
const html = fs.readFileSync('gymbro_redmi_simulator.html', 'utf8');
const deviceLab = fs.readFileSync('tooling/device_features_lab.html', 'utf8');
const foldablePreview = fs.readFileSync('tooling/foldable_preview.html', 'utf8');
const inlineScripts = [...html.matchAll(/<script(?![^>]*src)[^>]*>([\s\S]*?)<\/script>/gi)];

function assert(condition, message) {
  if (!condition) throw new Error(message);
}

assert(inlineScripts.length > 0, 'No inline JavaScript found.');
assert(html.includes('اوه، ببین کی داره پُز می‌ده بابا!'), 'Fold message is missing.');
assert(!html.includes('تمام تست‌ها پاس شدند'), 'Simulator must not claim unverified test success.');
assert(html.includes('تست سخت‌افزار واقعی انجام نشده است'), 'Physical-device limitation must be visible.');
assert(html.includes('Galaxy Z Fold 8'), 'Z Fold 8 QA profile label is missing.');
assert(deviceLab.includes('zfold8manual'), 'Z Fold 8 calibration preset is missing.');
assert(deviceLab.includes('onDeviceDimensionsInput'), 'Manual viewport calibration is not wired.');
assert(deviceLab.includes('مشخصات رسمی Z Fold 8'), 'Manual dimensions need a non-official-data disclaimer.');
assert(foldablePreview.includes('اوه، ببین کی داره پُز می‌ده بابا!'), 'Foldable preview message is out of sync.');

let parsedScriptCount = 0;
for (const [fileName, source] of [
  ['gymbro_redmi_simulator.html', html],
  ['tooling/device_features_lab.html', deviceLab],
  ['tooling/foldable_preview.html', foldablePreview],
]) {
  const scripts = [...source.matchAll(/<script(?![^>]*src)[^>]*>([\s\S]*?)<\/script>/gi)];
  for (const [index, script] of scripts.entries()) {
    new vm.Script(script[1], { filename: `${fileName}#script-${index + 1}` });
    parsedScriptCount++;
  }
}

const requiredIds = [
  'foldableToolbar',
  'btnPostureCover',
  'btnPostureFlex',
  'btnPostureFlat',
  'phoneChassis',
  'foldableEasterEggModal',
  'anatomySvgFront',
  'anatomySvgBack',
];
for (const id of requiredIds) {
  assert(new RegExp(`\\bid=["']${id}["']`).test(html), `Missing simulator control: ${id}`);
}

// Small DOM surface for deterministic JavaScript behavior checks.
global.window = { addEventListener: () => { } };
global.setTimeout = () => 1;
global.clearTimeout = () => { };
global.requestAnimationFrame = () => 1;
global.soundClick = () => { };
global.document = {
  elements: {},
  getElementById(id) {
    if (!this.elements[id]) {
      this.elements[id] = {
        id,
        classList: {
          classes: new Set(),
          add(c) { this.classes.add(c); },
          remove(c) { this.classes.delete(c); },
          contains(c) { return this.classes.has(c); }
        },
        className: '',
        style: {},
        innerHTML: '',
        textContent: id === 'foldableEasterEggModal'
          ? 'اوه، ببین کی داره پُز می‌ده بابا!'
          : '',
        querySelector: () => ({
          setAttribute: () => { },
          querySelector: () => null,
          className: ''
        }),
        querySelectorAll: () => [],
        setAttribute: () => { },
        getAttribute: () => ''
      };
    }
    return this.elements[id];
  },
  body: { appendChild: () => { } },
  createElement: () => ({ style: {}, appendChild: () => { }, classList: { add: () => { } } })
};

const behaviorChecks = `
  function assertState(condition, message) {
    if (!condition) throw new Error(message);
  }
  assertState(Object.keys(bodyScanZones).includes('chest'), 'Front chest region is missing.');
  assertState(Object.keys(bodyScanZones).includes('back'), 'Back region is missing.');
  selectBodyScanPart('chest');
  assertState(activeBodyScanKey === 'chest', 'Chest selection did not update.');
  switchAnatomyView('back');
  assertState(currentAnatomyView === 'back', 'Back view did not activate.');
  selectBodyScanPart('back');
  assertState(activeBodyScanKey === 'back', 'Back selection did not update.');
  switchAnatomyView('front');
  assertState(currentAnatomyView === 'front', 'Front view did not reactivate.');
  selectBodyScanPart('thigh');
  assertState(activeBodyScanKey === 'thigh', 'Thigh selection did not update.');
  hasShownEasterEggInSession = true;
  runFoldableAndCabbageTests();
  assertState(
    document.getElementById('gymbroGlobalToast').innerHTML.includes('شبیه‌سازی مرورگر'),
    'Foldable test runner did not report browser-simulation status.'
  );
  assertState(
    !document.getElementById('gymbroGlobalToast').innerHTML.includes('همه تست‌ها پاس شدند'),
    'Foldable test runner made an unverified pass claim.'
  );
  assertState(currentFoldPosture === 'flat', 'Foldable runner did not restore the previous posture.');
  hasShownEasterEggInSession = true;
  toggleFoldableMode();
  assertState(isFoldableMode, 'Foldable toolbar did not open.');
  setFoldPosture('folded');
  assertState(document.getElementById('phoneChassis').style.width === '392px', 'Cover posture failed.');
  setFoldPosture('tabletop');
  assertState(document.getElementById('phoneChassis').style.width === '540px', 'Tabletop posture failed.');
  setFoldPosture('flat');
  assertState(document.getElementById('phoneChassis').style.width === '680px', 'Unfolded posture failed.');
`;

try {
  eval(`${inlineScripts[0][1]}\n${behaviorChecks}`);
  console.log(`PASS: parsed ${parsedScriptCount} scripts; anatomy, fold postures, and Z Fold 8 calibration hooks.`);
  console.log('NOT TESTED: browser rendering, Android hinge sensor, and physical Z Fold 8 behavior.');
} catch (error) {
  console.error('FAIL:', error.message);
  process.exitCode = 1;
}
