<link href="Vazirmatn-font-face.css" rel="stylesheet" type="text/css" />
<script src="3.4.17.js"></script>
<script>tailwind.config = { theme: { extend: { fontFamily: { vazir: ['Vazirmatn', 'sans-serif'] } } } }</script>

<div dir="rtl" class="font-vazir text-slate-800" style="padding: 15px; width: 100%; box-sizing: border-box;">
    <div class="bg-white rounded-2xl shadow-md overflow-hidden border border-gray-100 flex flex-col" style="height: 260px; width: 100%; box-sizing: border-box;">
        
        <!-- هدر اپلت -->
        <div class="bg-rose-50 border-b border-rose-100 p-1.5 flex justify-between items-center">
            <div class="flex items-center gap-1.5 text-rose-600 font-bold text-xs">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"></path></svg>
                تماس‌های از دست رفته
            </div>
            <span id="missed-count-badge" class="bg-rose-600 text-white text-[10px] px-2 py-0.5 rounded-full font-bold">{$missed_count_today} مورد</span>
        </div>

        <!-- دکمه‌های تغییر دوره -->
        <div class="bg-slate-50 border-b border-gray-200 p-1 flex justify-center gap-1">
            <button onclick="switchMissedPeriod('day')" id="mbtn-day" style="background-color: #e11d48; color: white;" class="flex-1 py-1 rounded text-[10px] font-bold shadow-sm transition-all border border-rose-600">امروز</button>
            <button onclick="switchMissedPeriod('week')" id="mbtn-week" style="background-color: transparent; color: #64748b;" class="flex-1 py-1 rounded text-[10px] font-bold hover:bg-slate-200 transition-all border border-transparent">این هفته</button>
            <button onclick="switchMissedPeriod('month')" id="mbtn-month" style="background-color: transparent; color: #64748b;" class="flex-1 py-1 rounded text-[10px] font-bold hover:bg-slate-200 transition-all border border-transparent">این ماه</button>
            <button onclick="switchMissedPeriod('all')" id="mbtn-all" style="background-color: transparent; color: #64748b;" class="flex-1 py-1 rounded text-[10px] font-bold hover:bg-slate-200 transition-all border border-transparent">همه</button>
        </div>

        <!-- لیست تماس‌ها -->
        <div id="missed-list-container" class="flex-1 overflow-y-auto p-1.5">
            <!-- JS محتوا را اینجا قرار می‌دهد -->
        </div>

        <!-- کنترل‌های صفحه‌بندی -->
        <div id="pagination-controls" class="bg-slate-50 border-t border-gray-200 p-1 flex justify-center items-center gap-1.5">
            <!-- JS دکمه‌ها را اینجا قرار می‌دهد -->
        </div>
        
    </div>
</div>

<!-- المان مخفی برای نگهداری داده‌های JSON -->
<div id="missed-json-data" style="display:none;">{$missed_data_json}</div>

{literal}
<script>
(function() {
    var allPeriodsData = {};
    var currentPeriod = 'day';
    var currentPage = 1;
    var rowsPerPage = 5; 

    // دیکشنری ترجمه وضعیت‌ها به فارسی
    var dispositionMap = {
        'NO ANSWER': 'بدون پاسخ',
        'BUSY': 'اشغال',
        'FAILED': 'ناموفق',
        'ANSWERED': 'پاسخ داده شده'
    };

    var jsonText = document.getElementById('missed-json-data').innerText;
    try {
        allPeriodsData = JSON.parse(jsonText);
    } catch (e) {
        console.error("JSON Parse Error:", e);
    }

    var listContainer = document.getElementById('missed-list-container');
    var pagContainer = document.getElementById('pagination-controls');
    var countBadge = document.getElementById('missed-count-badge');

    window.switchMissedPeriod = function(period) {
        currentPeriod = period;
        
        ['day', 'week', 'month', 'all'].forEach(function(p) {
            var btn = document.getElementById('mbtn-' + p);
            if (p === period) {
                btn.style.backgroundColor = '#e11d48';
                btn.style.color = 'white';
                btn.className = 'flex-1 py-1 rounded text-[10px] font-bold shadow-sm transition-all border border-rose-600';
            } else {
                btn.style.backgroundColor = 'transparent';
                btn.style.color = '#64748b';
                btn.className = 'flex-1 py-1 rounded text-[10px] font-bold hover:bg-slate-200 transition-all border border-transparent';
            }
        });

        var data = allPeriodsData[period] || [];
        countBadge.innerText = data.length + ' مورد';

        renderMissedCalls(1);
    };

    function renderMissedCalls(page) {
        currentPage = page;
        listContainer.innerHTML = '';
        
        var data = allPeriodsData[currentPeriod] || [];

        if (data.length === 0) {
            listContainer.innerHTML = '<div class="h-full flex flex-col items-center justify-center text-slate-400 text-xs"><span class="text-2xl mb-1">🎉</span>تماسی یافت نشد</div>';
            pagContainer.innerHTML = '';
            return;
        }

        var start = (page - 1) * rowsPerPage;
        var end = start + rowsPerPage;
        var pageData = data.slice(start, end);

        pageData.forEach(function(call) {
            var d = new Date(call.calldate.replace(' ', 'T'));
            var timeOnly = d.toLocaleTimeString('fa-IR', {hour: '2-digit', minute:'2-digit'});
            var dateOnly = d.toLocaleDateString('fa-IR', { year: 'numeric', month: 'long', day: 'numeric' });
            var timeDisplay = (currentPeriod === 'day') ? timeOnly : dateOnly + ' - ' + timeOnly;
            
            // جایگزینی کلمه انگلیسی با معادل فارسی (اگر در دیکشنری نبود، خود کلمه انگلیسی را نشان می‌دهد)
            var statusFa = dispositionMap[call.disposition] || call.disposition;

            var html = `
                <div class="flex justify-between items-center bg-slate-50 p-1 rounded-lg border border-slate-100 mb-1">
                    <div class="flex items-center gap-1.5">
                        <div class="bg-rose-100 text-rose-500 p-1 rounded-full">
                            <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 8l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2M5 3a2 2 0 00-2 2v2.5A2.5 2.5 0 005.5 10H6a12.042 12.042 0 009.95 9.95v.05A2.5 2.5 0 0018.5 22H21a2 2 0 002-2v-3.5a2.5 2.5 0 00-2.5-2.5H19c-1.26 0-2.43-.31-3.46-.86M5 3h5v5H5V3z"></path></svg>
                        </div>
                        <div class="flex flex-col">
                            <span class="font-bold text-slate-700 text-[11px]" dir="ltr">${call.src}</span>
                            <div class="flex gap-1.5 mt-0.5 text-[9px] text-slate-500">
                                <span class="bg-slate-200 px-1 rounded">ترانک: ${call.trunk}</span>
                                <span>ورودی: <span dir="ltr">${call.dst}</span></span>
                            </div>
                        </div>
                    </div>
                    <div class="flex flex-col items-end">
                        <span class="text-[9px] text-slate-500 font-medium">${timeDisplay}</span>
                        <span class="text-[9px] text-rose-500 font-bold mt-0.5">${statusFa}</span>
                    </div>
                </div>
            `;
            listContainer.innerHTML += html;
        });

        renderPagination(data.length);
    }

    function renderPagination(totalItems) {
        var totalPages = Math.ceil(totalItems / rowsPerPage);
        pagContainer.innerHTML = '';

        if (totalPages <= 1) {
            pagContainer.innerHTML = '<span class="text-[9px] text-slate-400">پایان لیست</span>';
            return;
        }

        var prevBtn = document.createElement('button');
        prevBtn.className = `px-2 py-0.5 rounded text-[9px] border border-slate-300 ${currentPage === 1 ? 'bg-slate-100 text-slate-400 cursor-not-allowed' : 'bg-white text-slate-600 hover:bg-slate-50'}`;
        prevBtn.innerText = 'قبلی';
        prevBtn.onclick = function() { if(currentPage > 1) renderMissedCalls(currentPage - 1); };
        pagContainer.appendChild(prevBtn);

        var pageInfo = document.createElement('span');
        pageInfo.className = 'text-[9px] text-slate-600 font-bold px-1';
        pageInfo.innerText = currentPage + ' / ' + totalPages;
        pagContainer.appendChild(pageInfo);

        var nextBtn = document.createElement('button');
        nextBtn.className = `px-2 py-0.5 rounded text-[9px] border border-slate-300 ${currentPage === totalPages ? 'bg-slate-100 text-slate-400 cursor-not-allowed' : 'bg-white text-slate-600 hover:bg-slate-50'}`;
        nextBtn.innerText = 'بعدی';
        nextBtn.onclick = function() { if(currentPage < totalPages) renderMissedCalls(currentPage + 1); };
        pagContainer.appendChild(nextBtn);
    }

    switchMissedPeriod('day');
})();
</script>
{/literal}