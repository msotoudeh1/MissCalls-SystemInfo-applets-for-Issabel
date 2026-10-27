<?php
class Applet_IssabelAlarms
{
    function handleJSON_getContent($smarty, $module_name, $appletlist)
    {
        $alarms = array();
        $trunk_alarms = array();

        // ۱. بررسی وضعیت Asterisk
        $out = array();
        @exec('/usr/sbin/asterisk -rx "core show version" 2>&1', $out);
        if (empty($out) || stripos(implode(' ', $out), 'unable to connect') !== false) {
            $alarms[] = array('type' => 'critical', 'msg' => 'سرویس Asterisk متوقف شده است!');
        }

        // ۲. بررسی فضای هارد دیسک
        $total = @disk_total_space('/');
        $free = @disk_free_space('/');
        $disk_percent = 0; $total_gb = 0; $free_gb = 0;
        if ($total > 0) {
            $disk_percent = round((1 - ($free / $total)) * 100, 1);
            $total_gb = round($total / (1024 * 1024 * 1024), 1);
            $free_gb = round($free / (1024 * 1024 * 1024), 1);
            
            if ($disk_percent >= 90) {
                $alarms[] = array('type' => 'critical', 'msg' => 'فضای هارد دیسک بحرانی است (بیش از ۹۰٪ پر شده)!');
            } elseif ($disk_percent >= 75) {
                $alarms[] = array('type' => 'warning', 'msg' => 'فضای هارد دیسک رو به اتمام است (بیش از ۷۵٪ پر شده).');
            }
        }

        // ۳. بررسی مصرف RAM
        $ram_percent = 0; $ram_total = 0; $ram_used = 0;
        $free_out = array();
        @exec('free -m', $free_out);
        foreach ($free_out as $line) {
            if (preg_match('/^Mem:\s+(\d+)\s+(\d+)/', $line, $m)) {
                $ram_total = (int)$m[1];
                $ram_used = (int)$m[2];
                if ($ram_total > 0) {
                    $ram_percent = round(($ram_used / $ram_total) * 100, 1);
                }
                break;
            }
        }
        if ($ram_percent >= 90) {
            $alarms[] = array('type' => 'critical', 'msg' => 'مصرف رم (RAM) بحرانی است!');
        }

        // ۴. بررسی مصرف CPU (با استفاده از Load Average)
        $cpu_percent = 0;
        if (function_exists('sys_getloadavg')) {
            $load = sys_getloadavg();
            $cores = (int)shell_exec('nproc');
            if ($cores > 0) {
                $cpu_percent = round(($load[0] / $cores) * 100, 1);
                if ($cpu_percent > 100) $cpu_percent = 100;
            }
        }
        if ($cpu_percent >= 90) {
            $alarms[] = array('type' => 'warning', 'msg' => 'مصرف پردازنده (CPU) بسیار بالا است!');
        }

        // ۵. بررسی وضعیت دقیق ترانک‌ها (با استفاده از دیتابیس)
        try {
            $pdo = new PDO('mysql:host=localhost;dbname=asterisk;charset=utf8', 'asteriskuser', '123tosan8661');
            $stmt = $pdo->query("SELECT name, tech, channelid FROM trunks");
            $db_trunks = array();
            while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
                $trunk_name = trim(!empty($row['channelid']) ? $row['channelid'] : $row['name']);
                $db_trunks[$trunk_name] = array('tech' => strtoupper($row['tech']), 'status' => 'UNKNOWN');
            }

            $sip_out = array(); @exec('/usr/sbin/asterisk -rx "sip show peers" 2>/dev/null', $sip_out);
            $pjsip_out = array(); @exec('/usr/sbin/asterisk -rx "pjsip show endpoints" 2>/dev/null', $pjsip_out);

            foreach ($db_trunks as $name => $info) {
                if ($info['tech'] === 'PJSIP') {
                    foreach ($pjsip_out as $line) {
                        if (stripos($line, 'Endpoint: ' . $name) !== false) {
                            $db_trunks[$name]['status'] = (stripos($line, 'Unavailable') !== false || stripos($line, 'Unknown') !== false) ? 'UNREACHABLE' : 'OK';
                        }
                    }
                } else {
                    foreach ($sip_out as $line) {
                        if (stripos($line, $name . '/') !== false || stripos($line, $name . ' ') !== false) {
                            if (stripos($line, 'UNREACHABLE') !== false || stripos($line, 'UNKNOWN') !== false) {
                                $db_trunks[$name]['status'] = 'UNREACHABLE';
                            } else if (stripos($line, 'OK') !== false) {
                                $db_trunks[$name]['status'] = 'OK';
                            }
                        }
                    }
                }
            }

            foreach ($db_trunks as $name => $info) {
                if ($info['status'] === 'UNREACHABLE' || $info['status'] === 'UNKNOWN') {
                    $trunk_alarms[] = $name;
                }
            }

            if (count($trunk_alarms) > 0) {
                $alarms[] = array('type' => 'warning', 'msg' => 'ترانک(های) قطع شده: ' . implode(', ', $trunk_alarms));
            }
        } catch (PDOException $e) { }

        $smarty->assign('alarms', $alarms);
        $smarty->assign('alarm_count', count($alarms));
        
        // ارسال اطلاعات منابع سیستم
        $smarty->assign('disk_total_gb', $total_gb);
        $smarty->assign('disk_free_gb', $free_gb);
        $smarty->assign('disk_percent', $disk_percent);
        $smarty->assign('ram_total', $ram_total);
        $smarty->assign('ram_used', $ram_used);
        $smarty->assign('ram_percent', $ram_percent);
        $smarty->assign('cpu_percent', $cpu_percent);

        // تعیین رنگ‌ها
        $disk_color = ($disk_percent >= 90) ? 'rose' : (($disk_percent >= 75) ? 'amber' : 'emerald');
        $ram_color = ($ram_percent >= 90) ? 'rose' : (($ram_percent >= 75) ? 'amber' : 'blue');
        $cpu_color = ($cpu_percent >= 90) ? 'rose' : (($cpu_percent >= 75) ? 'amber' : 'indigo');
        
        $smarty->assign('disk_color', $disk_color);
        $smarty->assign('ram_color', $ram_color);
        $smarty->assign('cpu_color', $cpu_color);

        $html = $smarty->fetch('file:' . dirname(__FILE__) . '/tpl/alarms.tpl');

        header('Content-Type: application/json');
        return json_encode(array(
            'status' => 'success',
            'message' => '(no message)',
            'html' => $html
        ), JSON_UNESCAPED_UNICODE);
    }
}