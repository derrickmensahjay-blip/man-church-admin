<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Mighty Army Network — Admin</title>
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
<script src="https://cdn.jsdelivr.net/npm/qrcode@1.5.3/build/qrcode.min.js"></script>
<style>
* { box-sizing: border-box; margin: 0; padding: 0; }
body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; background: #f0f4f8; color: #1e293b; font-size: 15px; }
.sidebar { position: fixed; top: 0; left: 0; width: 220px; height: 100vh; background: #1a3a5c; color: white; padding: 1.5rem 1rem; display: flex; flex-direction: column; gap: 4px; z-index: 100; overflow-y: auto; }
.sidebar-logo { display: flex; align-items: center; gap: 10px; padding: 0 8px 1.25rem; border-bottom: 1px solid rgba(255,255,255,0.15); margin-bottom: 0.5rem; }
.sidebar-logo .icon { font-size: 24px; }
.sidebar-logo h1 { font-size: 14px; font-weight: 700; line-height: 1.3; }
.nav-item { padding: 9px 12px; border-radius: 8px; cursor: pointer; font-size: 13px; display: flex; align-items: center; gap: 9px; color: rgba(255,255,255,0.7); transition: all 0.15s; }
.nav-item:hover { background: rgba(255,255,255,0.1); color: white; }
.nav-item.active { background: rgba(255,255,255,0.18); color: white; font-weight: 500; }
.main { margin-left: 220px; padding: 1.5rem; min-height: 100vh; }
.page { display: none; }.page.active { display: block; }
.page-title { font-size: 20px; font-weight: 700; color: #1a3a5c; margin-bottom: 1.25rem; }
.stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 12px; margin-bottom: 1.5rem; }
.stat-card { background: white; border-radius: 12px; padding: 1.125rem; box-shadow: 0 1px 4px rgba(0,0,0,0.06); }
.stat-num { font-size: 30px; font-weight: 700; color: #1a3a5c; }
.stat-label { font-size: 12px; color: #64748b; margin-top: 4px; }
.card { background: white; border-radius: 12px; padding: 1.25rem; margin-bottom: 1.25rem; box-shadow: 0 1px 4px rgba(0,0,0,0.06); }
.card-title { font-size: 15px; font-weight: 600; color: #1a3a5c; margin-bottom: 1rem; }
table { width: 100%; border-collapse: collapse; font-size: 13px; }
th { text-align: left; padding: 9px 12px; font-size: 11px; font-weight: 600; color: #64748b; border-bottom: 1px solid #f1f5f9; background: #f8fafc; text-transform: uppercase; letter-spacing: 0.04em; }
td { padding: 10px 12px; border-bottom: 1px solid #f8fafc; vertical-align: middle; }
tr:hover td { background: #f8fafc; }
input, select, textarea { padding: 9px 12px; border: 1.5px solid #e2e8f0; border-radius: 8px; font-size: 14px; width: 100%; color: #1e293b; background: white; transition: border 0.15s; }
input:focus, select:focus, textarea:focus { outline: none; border-color: #1a3a5c; }
textarea { resize: vertical; min-height: 70px; }
label { display: block; font-size: 12px; font-weight: 600; color: #475569; margin-bottom: 4px; text-transform: uppercase; letter-spacing: 0.04em; }
.form-group { margin-bottom: 14px; }
.form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }
.form-row.s1 { grid-template-columns: 1fr; }
.btn { padding: 9px 18px; border-radius: 8px; font-size: 13px; font-weight: 600; cursor: pointer; border: none; transition: all 0.15s; }
.btn-primary { background: #1a3a5c; color: white; }.btn-primary:hover { background: #142e4a; }
.btn-success { background: #0F6E56; color: white; }
.btn-danger { background: #FCEBEB; color: #A32D2D; border: 1px solid #F09595; }
.btn-secondary { background: #f1f5f9; color: #475569; }
.btn-edit { background: #E6F1FB; color: #0C447C; border: 1px solid #B5D4F4; padding: 5px 10px; font-size: 12px; border-radius: 6px; cursor: pointer; font-weight: 600; }
.btn-sm { padding: 5px 12px; font-size: 12px; }
.badge { display: inline-block; padding: 3px 10px; border-radius: 20px; font-size: 11px; font-weight: 600; }
.badge-member { background: #9FE1CB; color: #04342C; }
.badge-visitor { background: #B5D4F4; color: #042C53; }
.badge-new { background: #FAC775; color: #412402; }
.badge-birthday { background: #F4C0D1; color: #4B1528; }
.badge-done { background: #C0DD97; color: #173404; }
.badge-pending { background: #F7C1C1; color: #501313; }
.alert { padding: 10px 14px; border-radius: 8px; font-size: 13px; margin-bottom: 1rem; }
.alert-success { background: #E1F5EE; color: #085041; border: 1px solid #5DCAA5; }
.alert-error { background: #FCEBEB; color: #501313; border: 1px solid #F09595; }
.alert-info { background: #E6F1FB; color: #042C53; border: 1px solid #85B7EB; }
.avatar { width: 32px; height: 32px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 12px; font-weight: 700; flex-shrink: 0; }
.member-cell { display: flex; align-items: center; gap: 10px; }
.search-row { display: flex; gap: 10px; margin-bottom: 1rem; align-items: center; }
.search-row input { flex: 1; }
.flex-between { display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem; flex-wrap: wrap; gap: 10px; }
.hidden { display: none !important; }
.edit-panel { background: #EFF6FF; border: 1.5px solid #B5D4F4; border-radius: 12px; padding: 1.25rem; margin-bottom: 1.25rem; }
.edit-panel .card-title { color: #0C447C; }
.tabs { display: flex; gap: 4px; border-bottom: 2px solid #f1f5f9; margin-bottom: 1.25rem; }
.tab { padding: 8px 16px; font-size: 13px; cursor: pointer; color: #64748b; border-bottom: 2px solid transparent; margin-bottom: -2px; font-weight: 500; }
.tab.active { color: #1a3a5c; border-bottom-color: #1a3a5c; }
.stabs { display: flex; gap: 8px; margin-bottom: 1rem; flex-wrap: wrap; }
.stab { padding: 6px 14px; border-radius: 20px; border: 1.5px solid #e2e8f0; font-size: 12px; cursor: pointer; color: #64748b; background: white; font-weight: 600; }
.stab.active { background: #1a3a5c; color: white; border-color: #1a3a5c; }
.pb { height: 6px; background: #f1f5f9; border-radius: 3px; overflow: hidden; margin-top: 5px; }
.pf { height: 100%; background: #1a3a5c; border-radius: 3px; }
.fu-row { display: flex; align-items: flex-start; gap: 12px; padding: 12px; border-bottom: 1px solid #f8fafc; }
.fu-row:last-child { border-bottom: none; }
.fu-actions { display: flex; flex-direction: column; align-items: flex-end; gap: 6px; flex-shrink: 0; }
.cw { display: flex; align-items: center; gap: 6px; cursor: pointer; font-size: 13px; }
.cw input[type=checkbox] { width: 16px; height: 16px; accent-color: #0F6E56; cursor: pointer; }
.bday-row { display: flex; align-items: center; justify-content: space-between; padding: 10px 12px; border-bottom: 1px solid #f8fafc; }
.bday-row:last-child { border-bottom: none; }
.nd { text-align: center; padding: 2.5rem; color: #94a3b8; font-size: 14px; }
.spinner { display: inline-block; width: 18px; height: 18px; border: 2px solid #e2e8f0; border-top-color: #1a3a5c; border-radius: 50%; animation: spin 0.7s linear infinite; vertical-align: middle; }
@keyframes spin { to { transform: rotate(360deg); } }
.loading-overlay { text-align: center; padding: 3rem; color: #64748b; }
.qr-wrap { display: flex; flex-direction: column; align-items: center; gap: 1rem; padding: 1rem 0; }
.qr-wrap canvas { border: 8px solid white; border-radius: 8px; box-shadow: 0 2px 12px rgba(0,0,0,0.1); }
.qr-url { font-size: 13px; color: #64748b; word-break: break-all; text-align: center; max-width: 400px; }
.chart-bars { display: flex; align-items: flex-end; gap: 10px; height: 100px; padding: 0 4px; }
.chart-bar-wrap { flex: 1; display: flex; flex-direction: column; align-items: center; gap: 4px; }
.chart-bar { width: 100%; background: #1a3a5c; border-radius: 4px 4px 0 0; min-height: 4px; }
.chart-label { font-size: 10px; color: #94a3b8; text-align: center; }
.chart-val { font-size: 11px; color: #475569; font-weight: 600; }
@media (max-width: 768px) {
  .sidebar { width: 100%; height: auto; position: relative; flex-direction: row; flex-wrap: wrap; padding: 0.75rem; }
  .sidebar-logo { padding-bottom: 0.75rem; width: 100%; }
  .main { margin-left: 0; }
  .form-row { grid-template-columns: 1fr; }
}
</style>
</head>
<body>

<div class="sidebar">
  <div class="sidebar-logo">
    <div class="icon">⛪</div>
    <h1>Mighty Army Network</h1>
  </div>
  <div class="nav-item active" onclick="showPage('dashboard',this)">📊 Dashboard</div>
  <div class="nav-item" onclick="showPage('checkin',this)">✅ Sunday Check-in</div>
  <div class="nav-item" onclick="showPage('members',this)">👥 Members</div>
  <div class="nav-item" onclick="showPage('attendance',this)">📋 Attendance</div>
  <div class="nav-item" onclick="showPage('birthdays',this)">🎂 Birthdays</div>
  <div class="nav-item" onclick="showPage('followup',this)">📞 Follow-up</div>
  <div class="nav-item" onclick="showPage('reports',this)">📈 Reports</div>
  <div class="nav-item" onclick="showPage('qrcode',this)">🔲 QR Code</div>
</div>

<div class="main">

<!-- DASHBOARD -->
<div class="page active" id="page-dashboard">
  <div class="page-title">Dashboard</div>
  <div class="stats-grid">
    <div class="stat-card"><div class="stat-num" id="s-members">—</div><div class="stat-label">Total Members</div></div>
    <div class="stat-card"><div class="stat-num" id="s-today">—</div><div class="stat-label">Today's Check-ins</div></div>
    <div class="stat-card"><div class="stat-num" id="s-visitors">—</div><div class="stat-label">All-time Visitors</div></div>
    <div class="stat-card"><div class="stat-num" id="s-bdays">—</div><div class="stat-label">Birthdays This Month</div></div>
    <div class="stat-card"><div class="stat-num" id="s-fu">—</div><div class="stat-label">Pending Follow-ups</div></div>
  </div>
  <div style="display:grid;grid-template-columns:2fr 1fr;gap:1.25rem">
    <div class="card"><div class="card-title">Recent Sunday attendance</div><div id="d-chart" style="min-height:60px"></div></div>
    <div class="card"><div class="card-title">Today's check-ins</div><div id="d-today-list" style="max-height:200px;overflow-y:auto"></div></div>
  </div>
  <div style="display:grid;grid-template-columns:1fr 1fr;gap:1.25rem">
    <div class="card"><div class="card-title">Upcoming birthdays (14 days)</div><div id="d-bdays"></div></div>
    <div class="card"><div class="card-title">Pending follow-ups</div><div id="d-fu"></div></div>
  </div>
</div>

<!-- CHECK-IN (admin manual) -->
<div class="page" id="page-checkin">
  <div class="page-title">Sunday Check-in</div>
  <div class="card">
    <div class="flex-between">
      <div class="card-title" style="margin-bottom:0">Service Date</div>
      <input type="date" id="svc-date" style="max-width:200px">
    </div>
  </div>
  <div class="card">
    <div class="card-title">Look up by phone number</div>
    <div class="search-row">
      <input type="tel" id="ci-phone" placeholder="Enter phone number..." onkeydown="if(event.key==='Enter')adminLookup()">
      <button class="btn btn-primary" onclick="adminLookup()">🔍 Look Up</button>
    </div>
    <div id="ci-result"></div>
    <div id="ci-visitor-form" class="hidden">
      <div style="background:#FAEEDA;border:1.5px solid #EF9F27;border-radius:10px;padding:1.25rem;margin-top:1rem">
        <div class="card-title" style="color:#633806;margin-bottom:1rem">📋 Register New Visitor</div>
        <input type="hidden" id="ci-v-phone">
        <div class="form-row"><div class="form-group"><label>First Name *</label><input id="ci-v-fn" placeholder="First name"></div><div class="form-group"><label>Last Name *</label><input id="ci-v-ln" placeholder="Last name"></div></div>
        <div class="form-row"><div class="form-group"><label>Email</label><input type="email" id="ci-v-em" placeholder="Optional"></div><div class="form-group"><label>Date of Birth</label><input type="date" id="ci-v-db"></div></div>
        <div class="form-row"><div class="form-group"><label>Gender</label><select id="ci-v-gn"><option value="">Select</option><option>Male</option><option>Female</option></select></div><div class="form-group"><label>Residential Area</label><input id="ci-v-ar" placeholder="e.g. Tema"></div></div>
        <div class="form-row"><div class="form-group"><label>How did you hear about us?</label><select id="ci-v-src"><option value="">Select</option><option>Friend / Family</option><option>Social Media</option><option>Flyer / Poster</option><option>Walked in</option><option>Other</option></select></div><div class="form-group"><label>Prayer Request</label><input id="ci-v-pr" placeholder="Optional"></div></div>
        <div style="display:flex;gap:10px;margin-top:8px">
          <button class="btn btn-success" onclick="adminRegisterVisitor()">Register &amp; Check In ✓</button>
          <button class="btn btn-secondary" onclick="document.getElementById('ci-visitor-form').classList.add('hidden')">Cancel</button>
        </div>
      </div>
    </div>
  </div>
  <div class="card">
    <div class="flex-between">
      <div class="card-title" style="margin-bottom:0">Today's check-ins (<span id="ci-count">0</span>)</div>
      <button class="btn btn-secondary btn-sm" onclick="clearTodayCheckins()">Clear today</button>
    </div>
    <div id="ci-list" style="margin-top:1rem;max-height:350px;overflow-y:auto"></div>
  </div>
</div>

<!-- MEMBERS -->
<div class="page" id="page-members">
  <div class="tabs">
    <div class="tab active" onclick="showMTab('list',this)">Member list</div>
    <div class="tab" onclick="showMTab('add',this)">Add member</div>
  </div>
  <div id="m-list-tab">
    <div class="search-row">
      <input id="m-search" placeholder="Search by name or phone..." oninput="renderMembers()">
      <select id="m-type-filter" onchange="renderMembers()" style="max-width:160px"><option value="">All types</option><option value="member">Member</option><option value="visitor">Visitor</option></select>
    </div>
    <div id="edit-wrap" class="hidden">
      <div class="edit-panel">
        <div class="card-title">✏️ Edit — <span id="ep-name"></span></div>
        <input type="hidden" id="ep-id">
        <div class="form-row"><div class="form-group"><label>First Name</label><input id="ep-fn"></div><div class="form-group"><label>Last Name</label><input id="ep-ln"></div></div>
        <div class="form-row"><div class="form-group"><label>Phone</label><input id="ep-ph"></div><div class="form-group"><label>Email</label><input type="email" id="ep-em"></div></div>
        <div class="form-row"><div class="form-group"><label>Gender</label><select id="ep-gn"><option value="">Select</option><option>Male</option><option>Female</option></select></div><div class="form-group"><label>Date of Birth</label><input type="date" id="ep-db"></div></div>
        <div class="form-row"><div class="form-group"><label>Residential Area</label><input id="ep-ar"></div><div class="form-group"><label>Cell Group / Unit</label><input id="ep-cl"></div></div>
        <div class="form-row"><div class="form-group"><label>Member Type</label><select id="ep-type"><option value="member">Church Member</option><option value="visitor">Visitor</option></select></div><div class="form-group"><label>Occupation</label><input id="ep-oc"></div></div>
        <div class="form-row s1"><div class="form-group"><label>Notes</label><textarea id="ep-nt"></textarea></div></div>
        <div style="display:flex;gap:10px;margin-top:4px">
          <button class="btn btn-primary" onclick="saveEdit()">Save Changes</button>
          <button class="btn btn-secondary" onclick="closeEdit()">Cancel</button>
        </div>
      </div>
    </div>
    <div class="card" style="padding:0;overflow:hidden">
      <table><thead><tr><th>Name</th><th>Phone</th><th>Birthday</th><th>Type</th><th>Cell Group</th><th>Visits</th><th>Actions</th></tr></thead><tbody id="m-tbody"></tbody></table>
    </div>
  </div>
  <div id="m-add-tab" class="hidden">
    <div class="card">
      <div class="card-title">Add new member / visitor</div>
      <div class="form-row"><div class="form-group"><label>First Name *</label><input id="a-fn" placeholder="First name"></div><div class="form-group"><label>Last Name *</label><input id="a-ln" placeholder="Last name"></div></div>
      <div class="form-row"><div class="form-group"><label>Phone *</label><input type="tel" id="a-ph" placeholder="e.g. 0244123456"></div><div class="form-group"><label>Email</label><input type="email" id="a-em" placeholder="Optional"></div></div>
      <div class="form-row"><div class="form-group"><label>Gender</label><select id="a-gn"><option value="">Select</option><option>Male</option><option>Female</option></select></div><div class="form-group"><label>Date of Birth</label><input type="date" id="a-db"></div></div>
      <div class="form-row"><div class="form-group"><label>Residential Area</label><input id="a-ar" placeholder="e.g. East Legon"></div><div class="form-group"><label>Occupation</label><input id="a-oc" placeholder="Optional"></div></div>
      <div class="form-row"><div class="form-group"><label>Member Type</label><select id="a-type"><option value="member">Church Member</option><option value="visitor">Visitor</option></select></div><div class="form-group"><label>Cell Group / Unit</label><input id="a-cl" placeholder="e.g. Young Adults, Choir"></div></div>
      <div class="form-row s1"><div class="form-group"><label>Notes</label><textarea id="a-nt" placeholder="Any additional notes..."></textarea></div></div>
      <div style="display:flex;gap:10px;margin-top:4px">
        <button class="btn btn-primary" onclick="addMember()">Save Member</button>
        <button class="btn btn-secondary" onclick="showMTab('list',null)">Cancel</button>
      </div>
    </div>
  </div>
</div>

<!-- ATTENDANCE -->
<div class="page" id="page-attendance">
  <div class="flex-between">
    <div class="page-title" style="margin-bottom:0">Attendance Records</div>
    <div style="display:flex;gap:10px;align-items:center">
      <input type="date" id="att-filter" style="max-width:180px" onchange="renderAttendance()">
      <button class="btn btn-secondary btn-sm" onclick="document.getElementById('att-filter').value='';renderAttendance()">Clear</button>
      <button class="btn btn-primary btn-sm" onclick="exportCSV()">⬇ Export CSV</button>
    </div>
  </div>
  <div style="height:1rem"></div>
  <div class="card" style="padding:0;overflow:hidden">
    <table><thead><tr><th>Date</th><th>Name</th><th>Phone</th><th>Type</th><th>Check-in Time</th></tr></thead><tbody id="att-tbody"></tbody></table>
  </div>
</div>

<!-- BIRTHDAYS -->
<div class="page" id="page-birthdays">
  <div class="page-title">Birthday Tracker</div>
  <div class="stabs">
    <div class="stab active" onclick="showBTab('upcoming',this)">Upcoming (30 days)</div>
    <div class="stab" onclick="showBTab('thismonth',this)">This month</div>
    <div class="stab" onclick="showBTab('all',this)">All members</div>
  </div>
  <div class="card" style="padding:0;overflow:hidden"><div id="bday-list"></div></div>
</div>

<!-- FOLLOW-UP -->
<div class="page" id="page-followup">
  <div class="page-title">Follow-up Tracker</div>
  <p style="font-size:13px;color:#64748b;margin-bottom:1rem">Members who missed at least one of the last 2 recorded Sundays.</p>
  <div class="flex-between">
    <div class="stabs" style="margin-bottom:0">
      <div class="stab active" onclick="showFTab('pending',this)">Pending</div>
      <div class="stab" onclick="showFTab('done',this)">Done</div>
      <div class="stab" onclick="showFTab('all',this)">All</div>
    </div>
    <button class="btn btn-secondary btn-sm" onclick="loadFollowups()">↻ Refresh</button>
  </div>
  <div style="height:1rem"></div>
  <div class="card" style="padding:0;overflow:hidden"><div id="fu-list"></div></div>
</div>

<!-- REPORTS -->
<div class="page" id="page-reports">
  <div class="page-title">Reports</div>
  <div class="card"><div class="card-title">Attendance by Sunday</div><div id="r-table"></div></div>
  <div class="card"><div class="card-title">Top attendees</div><div id="r-top"></div></div>
</div>

<!-- QR CODE -->
<div class="page" id="page-qrcode">
  <div class="page-title">QR Code — Self Check-in</div>
  <div class="card">
    <div class="card-title">Your check-in page URL</div>
    <p style="font-size:13px;color:#64748b;margin-bottom:1rem">After deploying, paste your check-in page URL below to generate a QR code to print and display at the church entrance.</p>
    <div class="search-row">
      <input type="url" id="qr-url-input" placeholder="https://your-checkin-url.vercel.app" oninput="generateQR()">
    </div>
    <div id="qr-output" class="qr-wrap" style="display:none">
      <canvas id="qr-canvas"></canvas>
      <div class="qr-url" id="qr-url-display"></div>
      <div style="display:flex;gap:10px">
        <button class="btn btn-primary" onclick="downloadQR()">⬇ Download QR Code</button>
        <button class="btn btn-secondary" onclick="printQR()">🖨 Print</button>
      </div>
    </div>
  </div>
  <div class="card">
    <div class="card-title">How to set up the QR check-in</div>
    <ol style="font-size:14px;color:#475569;line-height:2;padding-left:1.25rem">
      <li>Deploy this project to Vercel (see the <strong>SETUP_GUIDE.md</strong> file)</li>
      <li>Paste your check-in page URL above (e.g. <code style="background:#f1f5f9;padding:2px 6px;border-radius:4px">https://man-checkin.vercel.app</code>)</li>
      <li>Download or print the QR code</li>
      <li>Display it at the church entrance — members scan and check in themselves!</li>
    </ol>
  </div>
</div>

</div>

<script>
// =============================================
// CONFIGURATION — replace with your Supabase details
// =============================================
const SUPABASE_URL = 'https://ljejpmvlbtipgasxwhnk.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxqZWpwbXZsYnRpcGdhc3h3aG5rIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgyNzAzMzcsImV4cCI6MjA5Mzg0NjMzN30.taXJcYdZfJ6fZJ6BztSznBSVjJVhDbYxohzRuGOzCow';
// =============================================

const { createClient } = supabase;
const db = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

const today = new Date().toISOString().split('T')[0];
const COLS = ['#1a3a5c','#0F6E56','#993C1D','#533AB7','#854F0B','#3B6D11'];
function ac(str){ const h = String(str).split('').reduce((a,c)=>a+c.charCodeAt(0),0); return COLS[h%COLS.length]; }
function ini(f,l){ return ((f||'')[0]||'').toUpperCase()+((l||'')[0]||'').toUpperCase(); }
function fd(d){ if(!d) return ''; return new Date(d+'T00:00:00').toLocaleDateString('en-GH',{weekday:'short',year:'numeric',month:'short',day:'numeric'}); }
function fds(d){ if(!d) return ''; return new Date(d+'T00:00:00').toLocaleDateString('en-GH',{month:'short',day:'numeric'}); }
function dtb(dob){ if(!dob) return 999; const t=new Date(); t.setHours(0,0,0,0); const d=new Date(dob); let nx=new Date(t.getFullYear(),d.getMonth(),d.getDate()); if(nx<t)nx.setFullYear(t.getFullYear()+1); return Math.round((nx-t)/864e5); }
function fbf(dob){ if(!dob)return'—'; const d=new Date(dob+'T00:00:00'),age=new Date().getFullYear()-d.getFullYear(); return d.toLocaleDateString('en-GH',{month:'long',day:'numeric'})+` (turns ${age})`; }
function getSvcDate(){ const el=document.getElementById('svc-date'); return el&&el.value?el.value:today; }

// Init service date
document.getElementById('svc-date').value = today;

function showPage(id, el) {
  document.querySelectorAll('.page').forEach(p=>p.classList.remove('active'));
  document.querySelectorAll('.nav-item').forEach(n=>n.classList.remove('active'));
  document.getElementById('page-'+id).classList.add('active');
  if(el) el.classList.add('active');
  if(id==='dashboard') loadDashboard();
  if(id==='members') renderMembers();
  if(id==='attendance') renderAttendance();
  if(id==='birthdays') loadBirthdays('upcoming');
  if(id==='followup') loadFollowups('pending');
  if(id==='reports') loadReports();
  if(id==='checkin') renderCheckinList();
}

// ---- DASHBOARD ----
async function loadDashboard() {
  const [{ count: memCount }, { count: todayCount }, { count: visCount }, { data: attData }] = await Promise.all([
    db.from('members').select('id',{count:'exact',head:true}).eq('type','member'),
    db.from('attendance').select('id',{count:'exact',head:true}).eq('service_date',today),
    db.from('attendance').select('id',{count:'exact',head:true}).eq('first_visit',true),
    db.from('attendance').select('service_date').order('service_date',{ascending:false}).limit(200)
  ]);
  document.getElementById('s-members').textContent = memCount||0;
  document.getElementById('s-today').textContent = todayCount||0;
  document.getElementById('s-visitors').textContent = visCount||0;
  const mo = new Date().getMonth();
  const { count: bdCount } = await db.from('members').select('id',{count:'exact',head:true}).not('dob','is',null);
  const { data: allM } = await db.from('members').select('dob').not('dob','is',null);
  const bdMo = (allM||[]).filter(m=>new Date(m.dob).getMonth()===mo).length;
  document.getElementById('s-bdays').textContent = bdMo;
  await renderDashChart(attData||[]);
  await renderDashToday();
  await renderDashBdays();
  await renderDashFu();
}

async function renderDashChart(attData) {
  const sun = {};
  attData.forEach(a=>{ if(!sun[a.service_date])sun[a.service_date]=0; sun[a.service_date]++; });
  const dates = Object.keys(sun).sort().slice(-6);
  const el = document.getElementById('d-chart');
  if(!dates.length){ el.innerHTML='<div class="nd" style="padding:1rem">No attendance data yet.</div>'; return; }
  const mx = Math.max(...dates.map(d=>sun[d]),1);
  el.innerHTML = `<div class="chart-bars">${dates.map(d=>`<div class="chart-bar-wrap"><div class="chart-val">${sun[d]}</div><div class="chart-bar" style="height:${Math.round(sun[d]/mx*80)+4}px"></div><div class="chart-label">${d.slice(5)}</div></div>`).join('')}</div>`;
}

async function renderDashToday() {
  const { data } = await db.from('attendance').select('*').eq('service_date',today).order('created_at',{ascending:false}).limit(8);
  const el = document.getElementById('d-today-list');
  if(!data||!data.length){ el.innerHTML='<div class="nd" style="padding:1rem">No check-ins today.</div>'; return; }
  el.innerHTML = data.map(a=>`<div style="display:flex;justify-content:space-between;padding:7px 0;border-bottom:1px solid #f8fafc;font-size:13px"><span style="font-weight:500">${a.name} ${a.first_visit?'<span class="badge badge-new">New</span>':''}</span><span class="badge badge-${a.type}">${a.type}</span></div>`).join('');
}

async function renderDashBdays() {
  const { data } = await db.from('members').select('id,fname,lname,dob,phone').not('dob','is',null);
  const up = (data||[]).filter(m=>dtb(m.dob)<=14).sort((a,b)=>dtb(a.dob)-dtb(b.dob)).slice(0,5);
  const el = document.getElementById('d-bdays');
  el.innerHTML = up.length ? up.map(m=>{const d=dtb(m.dob);return`<div style="display:flex;justify-content:space-between;padding:7px 0;border-bottom:1px solid #f8fafc;font-size:13px"><span style="font-weight:500">${m.fname} ${m.lname}</span><span style="color:#64748b">${d===0?'Today!':'In '+d+' day'+(d===1?'':'s')}</span></div>`;}).join('') : '<div class="nd" style="padding:1rem">None in 14 days.</div>';
}

async function renderDashFu() {
  const pendingFu = await getPendingFU();
  const pending = pendingFu.filter(p=>!p.done).slice(0,5);
  document.getElementById('s-fu').textContent = pendingFu.filter(p=>!p.done).length;
  const el = document.getElementById('d-fu');
  el.innerHTML = pending.length ? pending.map(p=>`<div style="display:flex;justify-content:space-between;padding:7px 0;border-bottom:1px solid #f8fafc;font-size:13px"><span style="font-weight:500">${p.name}</span><span style="color:#E24B4A;font-size:12px">Missed ${fds(p.missed_date)}</span></div>`).join('') : '<div class="nd" style="padding:1rem">No pending follow-ups.</div>';
}

// ---- ADMIN CHECK-IN ----
async function adminLookup() {
  const phone = document.getElementById('ci-phone').value.trim().replace(/\s+/g,'');
  const res = document.getElementById('ci-result');
  if(!phone){ res.innerHTML='<div class="alert alert-error">Please enter a phone number.</div>'; return; }
  const svcDate = getSvcDate();
  const { data: already } = await db.from('attendance').select('id,name').eq('phone',phone).eq('service_date',svcDate).single();
  if(already){ res.innerHTML=`<div class="alert alert-info">⚠️ ${already.name} is already checked in for this service.</div>`; return; }
  const { data: member } = await db.from('members').select('*').eq('phone',phone).single();
  if(member){
    const { count } = await db.from('attendance').select('id',{count:'exact',head:true}).eq('member_id',member.id);
    res.innerHTML=`<div style="background:#E1F5EE;border:1px solid #5DCAA5;border-radius:10px;padding:1rem;margin-bottom:1rem"><div style="font-size:16px;font-weight:700;color:#085041;margin-bottom:4px">✓ ${member.fname} ${member.lname}</div><div style="font-size:13px;color:#0F6E56">📞 ${member.phone} · <span class="badge badge-${member.type}">${member.type}</span> · ${count||0} visits${member.cell_group?' · '+member.cell_group:''}</div><button class="btn btn-success btn-sm" style="margin-top:10px" onclick="adminCheckin('${member.id}','${member.fname} ${member.lname}','${member.phone}','${member.type}')">✅ Check In</button></div>`;
    document.getElementById('ci-visitor-form').classList.add('hidden');
  } else {
    document.getElementById('ci-v-phone').value = phone;
    ['ci-v-fn','ci-v-ln','ci-v-em','ci-v-db','ci-v-ar','ci-v-pr'].forEach(id=>document.getElementById(id).value='');
    document.getElementById('ci-visitor-form').classList.remove('hidden');
    res.innerHTML='<div class="alert alert-info">📋 New visitor — please fill in the form below.</div>';
  }
}

async function adminCheckin(memberId, name, phone, type) {
  const svcDate = getSvcDate();
  await db.from('attendance').insert({ member_id:memberId, name, phone, type, service_date:svcDate, check_in_time:new Date().toLocaleTimeString('en-GH',{hour:'2-digit',minute:'2-digit'}), first_visit:false });
  document.getElementById('ci-result').innerHTML=`<div class="alert alert-success">✅ ${name} checked in successfully!</div>`;
  document.getElementById('ci-phone').value='';
  renderCheckinList();
}

async function adminRegisterVisitor() {
  const fn=document.getElementById('ci-v-fn').value.trim(), ln=document.getElementById('ci-v-ln').value.trim(), ph=document.getElementById('ci-v-phone').value;
  if(!fn||!ln){ alert('Please enter first and last name.'); return; }
  const { data: member } = await db.from('members').insert({ fname:fn,lname:ln,phone:ph,email:document.getElementById('ci-v-em').value.trim(),gender:document.getElementById('ci-v-gn').value,dob:document.getElementById('ci-v-db').value||null,area:document.getElementById('ci-v-ar').value.trim(),source:document.getElementById('ci-v-src').value,prayer:document.getElementById('ci-v-pr').value.trim(),type:'visitor',joined:getSvcDate() }).select().single();
  if(!member){ alert('Error saving visitor.'); return; }
  await db.from('attendance').insert({ member_id:member.id,name:fn+' '+ln,phone:ph,type:'visitor',service_date:getSvcDate(),check_in_time:new Date().toLocaleTimeString('en-GH',{hour:'2-digit',minute:'2-digit'}),first_visit:true });
  document.getElementById('ci-visitor-form').classList.add('hidden');
  document.getElementById('ci-result').innerHTML=`<div class="alert alert-success">🎉 ${fn} ${ln} registered and checked in! Welcome to Mighty Army Network!</div>`;
  document.getElementById('ci-phone').value='';
  renderCheckinList();
}

async function renderCheckinList() {
  const svcDate = getSvcDate();
  const { data } = await db.from('attendance').select('*').eq('service_date',svcDate).order('created_at',{ascending:false});
  document.getElementById('ci-count').textContent=(data||[]).length;
  const el=document.getElementById('ci-list');
  if(!data||!data.length){ el.innerHTML='<div class="nd">No check-ins yet for this service date.</div>'; return; }
  el.innerHTML=data.map(a=>{const col=ac(a.member_id||a.name);return`<div style="display:flex;align-items:center;justify-content:space-between;padding:8px 12px;border-bottom:1px solid #f8fafc"><div style="display:flex;align-items:center;gap:10px"><div class="avatar" style="background:${col}22;color:${col}">${ini(a.name.split(' ')[0],a.name.split(' ')[1])}</div><div><div style="font-weight:500;font-size:14px">${a.name} ${a.first_visit?'<span class="badge badge-new">New</span>':''}</div><div style="font-size:12px;color:#64748b">${a.phone}</div></div></div><div style="text-align:right"><span class="badge badge-${a.type}">${a.type}</span><div style="font-size:11px;color:#94a3b8;margin-top:2px">${a.check_in_time||''}</div></div></div>`;}).join('');
}

async function clearTodayCheckins() {
  if(!confirm('Clear all check-ins for today?')) return;
  await db.from('attendance').delete().eq('service_date',getSvcDate());
  renderCheckinList();
}

// ---- MEMBERS ----
async function renderMembers() {
  const srch=(document.getElementById('m-search')?.value||'').toLowerCase();
  const filt=document.getElementById('m-type-filter')?.value||'';
  let q = db.from('members').select('*').order('lname');
  if(filt) q=q.eq('type',filt);
  const { data } = await q;
  let mems = (data||[]).filter(m=>(m.fname+' '+m.lname).toLowerCase().includes(srch)||m.phone.includes(srch));
  const tb=document.getElementById('m-tbody');
  if(!mems.length){ tb.innerHTML='<tr><td colspan="7" class="nd">No members found.</td></tr>'; return; }
  const memberIds = mems.map(m=>m.id);
  const { data: attCounts } = await db.from('attendance').select('member_id').in('member_id',memberIds);
  const counts = {};
  (attCounts||[]).forEach(a=>{ counts[a.member_id]=(counts[a.member_id]||0)+1; });
  tb.innerHTML=mems.map(m=>{
    const col=ac(m.id),visits=counts[m.id]||0,soon=m.dob&&dtb(m.dob)<=30;
    return`<tr><td><div class="member-cell"><div class="avatar" style="background:${col}22;color:${col}">${ini(m.fname,m.lname)}</div><div><div style="font-weight:500">${m.fname} ${m.lname}</div><div style="font-size:11px;color:#64748b">${m.area||''}</div></div></div></td><td>${m.phone}</td><td>${m.dob?fds(m.dob):'—'} ${soon?'<span class="badge badge-birthday">Soon</span>':''}</td><td><span class="badge badge-${m.type}">${m.type}</span></td><td style="font-size:12px">${m.cell_group||'—'}</td><td>${visits}</td><td style="white-space:nowrap"><button class="btn-edit" onclick="openEdit('${m.id}')">✏️ Edit</button> <button class="btn btn-danger btn-sm" onclick="delMember('${m.id}')">Remove</button></td></tr>`;
  }).join('');
}

async function openEdit(id) {
  const { data: m } = await db.from('members').select('*').eq('id',id).single();
  if(!m) return;
  document.getElementById('ep-id').value=m.id;
  document.getElementById('ep-name').textContent=m.fname+' '+m.lname;
  document.getElementById('ep-fn').value=m.fname;
  document.getElementById('ep-ln').value=m.lname;
  document.getElementById('ep-ph').value=m.phone;
  document.getElementById('ep-em').value=m.email||'';
  document.getElementById('ep-gn').value=m.gender||'';
  document.getElementById('ep-db').value=m.dob||'';
  document.getElementById('ep-ar').value=m.area||'';
  document.getElementById('ep-cl').value=m.cell_group||'';
  document.getElementById('ep-type').value=m.type;
  document.getElementById('ep-oc').value=m.occupation||'';
  document.getElementById('ep-nt').value=m.notes||'';
  document.getElementById('edit-wrap').classList.remove('hidden');
  document.getElementById('edit-wrap').scrollIntoView({behavior:'smooth',block:'start'});
}

function closeEdit() { document.getElementById('edit-wrap').classList.add('hidden'); }

async function saveEdit() {
  const id=document.getElementById('ep-id').value;
  const fn=document.getElementById('ep-fn').value.trim(),ln=document.getElementById('ep-ln').value.trim();
  if(!fn||!ln){ alert('Name cannot be empty.'); return; }
  const type=document.getElementById('ep-type').value;
  await db.from('members').update({ fname:fn,lname:ln,phone:document.getElementById('ep-ph').value.trim(),email:document.getElementById('ep-em').value.trim(),gender:document.getElementById('ep-gn').value,dob:document.getElementById('ep-db').value||null,area:document.getElementById('ep-ar').value.trim(),cell_group:document.getElementById('ep-cl').value.trim(),type,occupation:document.getElementById('ep-oc').value.trim(),notes:document.getElementById('ep-nt').value.trim() }).eq('id',id);
  await db.from('attendance').update({name:fn+' '+ln,type}).eq('member_id',id);
  closeEdit(); renderMembers(); alert(`${fn} ${ln} updated successfully!`);
}

async function delMember(id) {
  if(!confirm('Remove this person from the database?')) return;
  await db.from('members').delete().eq('id',id);
  closeEdit(); renderMembers();
}

async function addMember() {
  const fn=document.getElementById('a-fn').value.trim(),ln=document.getElementById('a-ln').value.trim(),ph=document.getElementById('a-ph').value.trim();
  if(!fn||!ln||!ph){ alert('Please fill in name and phone number.'); return; }
  const { error } = await db.from('members').insert({ fname:fn,lname:ln,phone:ph,email:document.getElementById('a-em').value.trim(),gender:document.getElementById('a-gn').value,dob:document.getElementById('a-db').value||null,area:document.getElementById('a-ar').value.trim(),occupation:document.getElementById('a-oc').value.trim(),type:document.getElementById('a-type').value,cell_group:document.getElementById('a-cl').value.trim(),notes:document.getElementById('a-nt').value.trim(),joined:today });
  if(error){ alert('Error: '+error.message); return; }
  ['a-fn','a-ln','a-ph','a-em','a-ar','a-oc','a-cl','a-nt','a-db'].forEach(id=>document.getElementById(id).value='');
  showMTab('list',null); renderMembers(); alert(`${fn} ${ln} added successfully!`);
}

function showMTab(tab,el) {
  document.querySelectorAll('#page-members .tab').forEach(t=>t.classList.remove('active'));
  if(el)el.classList.add('active');
  else document.querySelectorAll('#page-members .tab')[tab==='list'?0:1].classList.add('active');
  document.getElementById('m-list-tab').classList.toggle('hidden',tab!=='list');
  document.getElementById('m-add-tab').classList.toggle('hidden',tab!=='add');
  if(tab==='list'){ closeEdit(); renderMembers(); }
}

// ---- ATTENDANCE ----
async function renderAttendance() {
  const fd=document.getElementById('att-filter')?.value;
  let q=db.from('attendance').select('*').order('service_date',{ascending:false}).order('created_at',{ascending:false});
  if(fd) q=q.eq('service_date',fd);
  const { data } = await q.limit(300);
  const tb=document.getElementById('att-tbody');
  if(!data||!data.length){ tb.innerHTML='<tr><td colspan="5" class="nd">No records found.</td></tr>'; return; }
  tb.innerHTML=data.map(a=>`<tr><td style="font-size:12px">${fd_full(a.service_date)}</td><td style="font-weight:500">${a.name} ${a.first_visit?'<span class="badge badge-new">New</span>':''}</td><td style="font-size:12px">${a.phone}</td><td><span class="badge badge-${a.type}">${a.type}</span></td><td style="font-size:12px;color:#64748b">${a.check_in_time||''}</td></tr>`).join('');
}

function fd_full(d){ if(!d)return''; return new Date(d+'T00:00:00').toLocaleDateString('en-GH',{weekday:'short',year:'numeric',month:'short',day:'numeric'}); }

async function exportCSV() {
  const { data } = await db.from('attendance').select('*').order('service_date',{ascending:false});
  const rows=[['Date','Name','Phone','Type','Time','First Visit']];
  (data||[]).forEach(a=>rows.push([a.service_date,a.name,a.phone,a.type,a.check_in_time||'',a.first_visit?'Yes':'No']));
  const csv=rows.map(r=>r.map(c=>'"'+String(c).replace(/"/g,'""')+'"').join(',')).join('\n');
  const blob=new Blob([csv],{type:'text/csv'}),url=URL.createObjectURL(blob),a=document.createElement('a');
  a.href=url;a.download='MAN_attendance.csv';a.click();
}

// ---- BIRTHDAYS ----
let bdayTab='upcoming';
function showBTab(tab,el){ bdayTab=tab; document.querySelectorAll('#page-birthdays .stab').forEach(s=>s.classList.remove('active')); if(el)el.classList.add('active'); loadBirthdays(tab); }

async function loadBirthdays(tab='upcoming') {
  bdayTab=tab;
  const { data } = await db.from('members').select('id,fname,lname,dob,phone,type').not('dob','is',null);
  let mems=[...data||[]];
  if(tab==='upcoming') mems=mems.filter(m=>dtb(m.dob)<=30).sort((a,b)=>dtb(a.dob)-dtb(b.dob));
  else if(tab==='thismonth'){ const mo=new Date().getMonth(); mems=mems.filter(m=>new Date(m.dob).getMonth()===mo).sort((a,b)=>new Date(a.dob).getDate()-new Date(b.dob).getDate()); }
  else mems.sort((a,b)=>{ const da=new Date(a.dob),db2=new Date(b.dob); return(da.getMonth()*100+da.getDate())-(db2.getMonth()*100+db2.getDate()); });
  const el=document.getElementById('bday-list');
  if(!mems.length){ el.innerHTML='<div class="nd">No birthdays found.</div>'; return; }
  el.innerHTML=mems.map(m=>{ const days=dtb(m.dob),col=ac(m.id); const tag=days===0?'<span class="badge badge-birthday">Today! 🎂</span>':days<=7?`<span class="badge badge-birthday">In ${days} days</span>`:`<span style="font-size:12px;color:#64748b">In ${days} days</span>`; return`<div class="bday-row"><div style="display:flex;align-items:center;gap:10px"><div class="avatar" style="background:${col}22;color:${col}">${ini(m.fname,m.lname)}</div><div><div style="font-weight:500;font-size:14px">${m.fname} ${m.lname}</div><div style="font-size:12px;color:#64748b">${fbf(m.dob)} · ${m.phone}</div></div></div><div>${tag}</div></div>`; }).join('');
}

// ---- FOLLOW-UP ----
let fuTab='pending';
async function getPendingFU() {
  const { data: attData } = await db.from('attendance').select('service_date').order('service_date',{ascending:false}).limit(500);
  const dates=[...new Set((attData||[]).map(a=>a.service_date))].slice(0,2);
  if(!dates.length) return [];
  const { data: members } = await db.from('members').select('id,fname,lname,phone,cell_group').eq('type','member');
  const { data: attended } = await db.from('attendance').select('member_id,service_date').in('service_date',dates);
  const { data: fuData } = await db.from('followups').select('*').in('missed_date',dates);
  const attendedSet = new Set((attended||[]).map(a=>a.member_id+'_'+a.service_date));
  const fuMap = {};
  (fuData||[]).forEach(f=>{ fuMap[f.member_id+'_'+f.missed_date]=f; });
  const results=[];
  (members||[]).forEach(m=>{ dates.forEach(date=>{ if(!attendedSet.has(m.id+'_'+date)){ const fu=fuMap[m.id+'_'+date]||{}; results.push({id:m.id,name:m.fname+' '+m.lname,phone:m.phone,cell:m.cell_group||'',missed_date:date,done:fu.done||false,note:fu.note||'',fu_id:fu.id||null}); } }); });
  return results;
}

function showFTab(tab,el){ fuTab=tab; document.querySelectorAll('#page-followup .stab').forEach(s=>s.classList.remove('active')); if(el)el.classList.add('active'); loadFollowups(); }

async function loadFollowups(tab) {
  if(tab) fuTab=tab;
  const all=await getPendingFU();
  const items=fuTab==='pending'?all.filter(p=>!p.done):fuTab==='done'?all.filter(p=>p.done):all;
  const el=document.getElementById('fu-list');
  if(!items.length){ el.innerHTML=`<div class="nd">${fuTab==='pending'?'No pending follow-ups — all caught up! ✓':fuTab==='done'?'No completed follow-ups yet.':'No missed services in the last 2 recorded Sundays.'}</div>`; return; }
  el.innerHTML=items.map(p=>{ const col=ac(p.id); return`<div class="fu-row"><div class="avatar" style="background:${col}22;color:${col}">${ini(p.name.split(' ')[0],p.name.split(' ')[1])}</div><div style="flex:1"><div style="font-weight:500;font-size:14px">${p.name}</div><div style="font-size:12px;color:#64748b">📞 ${p.phone}${p.cell?' · '+p.cell:''}</div><div style="font-size:12px;color:#E24B4A">Missed: ${fd(p.missed_date)}</div>${p.note?`<div style="font-size:12px;color:#64748b;font-style:italic;margin-top:3px">Note: ${p.note}</div>`:''}</div><div class="fu-actions"><label class="cw"><input type="checkbox" ${p.done?'checked':''} onchange="toggleFU('${p.id}','${p.missed_date}',this)"> <span style="font-size:13px">${p.done?'<span class="badge badge-done">Done</span>':'<span class="badge badge-pending">Pending</span>'}</span></label><button class="btn btn-secondary btn-sm" onclick="addFUNote('${p.id}','${p.missed_date}')">Add note</button></div></div>`; }).join('');
}

async function toggleFU(memberId, missedDate, cb) {
  const done=cb.checked;
  const { data: existing } = await db.from('followups').select('id').eq('member_id',memberId).eq('missed_date',missedDate).single();
  if(existing){ await db.from('followups').update({done,done_at:done?new Date().toISOString():null}).eq('id',existing.id); }
  else{ await db.from('followups').insert({member_id:memberId,missed_date:missedDate,done,done_at:done?new Date().toISOString():null}); }
  loadFollowups(); loadDashboard();
}

async function addFUNote(memberId, missedDate) {
  const note=prompt('Add a follow-up note (e.g. "Called, will be back next Sunday"):');
  if(note===null) return;
  const { data: existing } = await db.from('followups').select('id').eq('member_id',memberId).eq('missed_date',missedDate).single();
  if(existing){ await db.from('followups').update({note}).eq('id',existing.id); }
  else{ await db.from('followups').insert({member_id:memberId,missed_date:missedDate,note,done:false}); }
  loadFollowups();
}

// ---- REPORTS ----
async function loadReports() {
  const { data } = await db.from('attendance').select('service_date,type,first_visit').order('service_date',{ascending:false}).limit(1000);
  const sun={};
  (data||[]).forEach(a=>{ if(!sun[a.service_date])sun[a.service_date]={total:0,members:0,visitors:0,newV:0}; sun[a.service_date].total++; if(a.type==='member')sun[a.service_date].members++; else sun[a.service_date].visitors++; if(a.first_visit)sun[a.service_date].newV++; });
  const dates=Object.keys(sun).sort().reverse();
  const el=document.getElementById('r-table');
  el.innerHTML=dates.length?`<table><thead><tr><th>Date</th><th>Total</th><th>Members</th><th>Visitors</th><th>New visitors</th></tr></thead><tbody>`+dates.map(d=>`<tr><td style="font-size:12px">${fd_full(d)}</td><td><strong>${sun[d].total}</strong></td><td>${sun[d].members}</td><td>${sun[d].visitors}</td><td>${sun[d].newV}</td></tr>`).join('')+`</tbody></table>`:'<div class="nd">No records yet.</div>';
  const names={};
  (data||[]).forEach(a=>{ if(!names[a.name])names[a.name]=0; names[a.name]++; });
  const sorted=Object.entries(names).sort((a,b)=>b[1]-a[1]).slice(0,10);
  const te=document.getElementById('r-top');
  const mx=sorted[0]?.[1]||1;
  te.innerHTML=sorted.length?sorted.map(([n,c])=>`<div style="margin-bottom:12px"><div style="display:flex;justify-content:space-between;margin-bottom:4px"><span style="font-size:13px">${n}</span><span style="font-size:13px;font-weight:600">${c} visits</span></div><div class="pb"><div class="pf" style="width:${Math.round(c/mx*100)}%"></div></div></div>`).join(''):'<div class="nd">No data yet.</div>';
}

// ---- QR CODE ----
function generateQR() {
  const url=document.getElementById('qr-url-input').value.trim();
  const out=document.getElementById('qr-output');
  if(!url){ out.style.display='none'; return; }
  out.style.display='flex';
  document.getElementById('qr-url-display').textContent=url;
  QRCode.toCanvas(document.getElementById('qr-canvas'),url,{width:220,margin:2,color:{dark:'#1a3a5c',light:'#ffffff'}});
}

function downloadQR() {
  const canvas=document.getElementById('qr-canvas');
  const a=document.createElement('a'); a.href=canvas.toDataURL(); a.download='MAN_checkin_qr.png'; a.click();
}

function printQR() {
  const canvas=document.getElementById('qr-canvas');
  const url=document.getElementById('qr-url-display').textContent;
  const win=window.open('','_blank');
  win.document.write(`<html><body style="text-align:center;font-family:sans-serif;padding:2rem"><h2 style="color:#1a3a5c">Mighty Army Network</h2><p style="color:#64748b;margin-bottom:1.5rem">Scan to check in for today's service</p><img src="${canvas.toDataURL()}" style="width:220px"><p style="font-size:12px;color:#94a3b8;margin-top:1rem">${url}</p></body></html>`);
  win.print();
}

// Init
loadDashboard();
</script>
</body>
</html>
