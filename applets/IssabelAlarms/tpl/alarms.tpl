<link href="Vazirmatn-font-face.css" rel="stylesheet" type="text/css" />
<script src="3.4.17.js"></script>
<script>tailwind.config = { theme: { extend: { fontFamily: { vazir: ['Vazirmatn', 'sans-serif'] } } } }</script>

<div dir="rtl" class="font-vazir text-slate-800" style="padding: 15px; width: 100%; box-sizing: border-box;">
    <div class="bg-white rounded-2xl shadow-md overflow-hidden border border-gray-100 flex flex-col" style="height: 260px; width: 100%; box-sizing: border-box;">
        
        <!-- بخش بالایی: منابع سیستم -->
        <div class="p-2.5 border-b border-gray-200 bg-slate-50 space-y-2">
            
            <!-- هدر -->
            <div class="flex justify-between items-center mb-1">
                <div class="flex items-center gap-1.5 font-bold text-xs {if $alarm_count > 0} text-rose-600 {else} text-emerald-600 {/if}">
                    {if $alarm_count > 0}
                        <svg class="w-4 h-4 animate-pulse" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"></path></svg>
                        هشدارهای سیستم
                    {else}
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                        وضعیت سیستم
                    {/if}
                </div>
                {if $alarm_count > 0}
                    <span class="bg-rose-500 text-white text-[10px] px-1.5 py-0.5 rounded-full font-bold">{$alarm_count} هشدار</span>
                {/if}
            </div>

            <!-- نوار هارد دیسک -->
            <div class="bg-white p-1.5 rounded-lg border border-gray-200 shadow-sm">
                <div class="flex justify-between items-center mb-1">
                    <div class="text-[10px] font-bold text-gray-600 flex items-center gap-1">
                        <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 7v10c0 2.21 3.582 4 8 4s8-1.79 8-4V7M4 7c0 2.21 3.582 4 8 4s8-1.79 8-4M4 7c0-2.21 3.582-4 8-4s8 1.79 8 4zm0 5c0 2.21 3.582 4 8 4s8-1.79 8-4"></path></svg>
                        هارد دیسک
                    </div>
                    <div class="text-[9px] text-gray-500 font-medium">{$disk_free_gb}GB آزاد از {$disk_total_gb}GB</div>
                </div>
                <div class="w-full bg-gray-200 rounded-full h-1.5">
                    <div class="bg-{$disk_color}-500 h-1.5 rounded-full" style="width: {$disk_percent}%"></div>
                </div>
            </div>

            <!-- نوار رم (RAM) -->
            <div class="bg-white p-1.5 rounded-lg border border-gray-200 shadow-sm">
                <div class="flex justify-between items-center mb-1">
                    <div class="text-[10px] font-bold text-gray-600 flex items-center gap-1">
                        <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 3v2m6-2v2M9 19v2m6-2v2M5 9H3m2 6H3m18-6h-2m2 6h-2M7 19h10a2 2 0 002-2V7a2 2 0 00-2-2H7a2 2 0 00-2 2v10a2 2 0 002 2zM9 9h6v6H9V9z"></path></svg>
                        حافظه رم (RAM)
                    </div>
                    <div class="text-[9px] text-gray-500 font-medium">{$ram_used}MB از {$ram_total}MB</div>
                </div>
                <div class="w-full bg-gray-200 rounded-full h-1.5">
                    <div class="bg-{$ram_color}-500 h-1.5 rounded-full" style="width: {$ram_percent}%"></div>
                </div>
            </div>

            <!-- نوار پردازنده (CPU) -->
            <div class="bg-white p-1.5 rounded-lg border border-gray-200 shadow-sm">
                <div class="flex justify-between items-center mb-1">
                    <div class="text-[10px] font-bold text-gray-600 flex items-center gap-1">
                        <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path></svg>
                        پردازنده (CPU)
                    </div>
                    <div class="text-[9px] text-gray-500 font-medium">{$cpu_percent}%</div>
                </div>
                <div class="w-full bg-gray-200 rounded-full h-1.5">
                    <div class="bg-{$cpu_color}-500 h-1.5 rounded-full" style="width: {$cpu_percent}%"></div>
                </div>
            </div>
        </div>

        <!-- بخش پایینی: لیست هشدارها -->
        <div class="flex-1 overflow-y-auto p-2 bg-white">
            {if $alarm_count > 0}
                <ul class="space-y-1">
                    {foreach $alarms as $alarm}
                    <li class="flex items-start gap-1.5 bg-rose-50 p-1.5 rounded-lg border border-rose-100">
                        <div class="mt-0.5 text-rose-500">
                            <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                        </div>
                        <span class="text-[10px] font-medium text-rose-700 leading-relaxed">{$alarm.msg}</span>
                    </li>
                    {/foreach}
                </ul>
            {else}
                <div class="h-full flex flex-col items-center justify-center text-emerald-600 pb-2">
                    <div class="bg-emerald-50 p-1.5 rounded-full mb-1">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path></svg>
                    </div>
                    <span class="text-[11px] font-bold">تمام سیستم‌ها سالم هستند</span>
                </div>
            {/if}
        </div>
    </div>
</div>