<?php
class Applet_IssabelMissedCalls
{
    function handleJSON_getContent($smarty, $module_name, $appletlist)
    {
        $missed_day = $this->fetchMissedCalls('day');
        $missed_week = $this->fetchMissedCalls('week');
        $missed_month = $this->fetchMissedCalls('month');
        $missed_all = $this->fetchMissedCalls('all');

        $period_data = array(
            'day' => $missed_day,
            'week' => $missed_week,
            'month' => $missed_month,
            'all' => $missed_all
        );

        // ارسال داده‌های همه دوره‌ها به صورت JSON
        $smarty->assign('missed_data_json', json_encode($period_data, JSON_UNESCAPED_UNICODE));
        $smarty->assign('missed_count_today', count($missed_day));

        $html = $smarty->fetch('file:' . dirname(__FILE__) . '/tpl/missed.tpl');

        header('Content-Type: application/json');
        return json_encode(array(
            'status' => 'success',
            'message' => '(no message)',
            'html' => $html
        ), JSON_UNESCAPED_UNICODE);
    }

    private function fetchMissedCalls($period) {
        $missed = array();
        try {
            $pdo = new PDO('mysql:host=localhost;dbname=asteriskcdrdb;charset=utf8', 'asteriskuser', 'database_password');
            $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            
            $where = "DATE(calldate) = CURDATE()";
            if ($period == 'week') {
                $where = "YEARWEEK(calldate, 1) = YEARWEEK(CURDATE(), 1)";
            } elseif ($period == 'month') {
                $where = "MONTH(calldate) = MONTH(CURDATE()) AND YEAR(calldate) = YEAR(CURDATE())";
            } elseif ($period == 'all') {
                $where = "1=1"; // همه زمان‌ها
            }
            
            $limit = ($period == 'all') ? 200 : 100;

            $sql = "SELECT calldate, src, dst, channel, dcontext, disposition 
                    FROM cdr 
                    WHERE $where 
                      AND disposition IN ('NO ANSWER', 'BUSY', 'FAILED') 
                      AND (dcontext LIKE 'from-did%' OR dcontext LIKE 'from-trunk%' OR dcontext LIKE 'from-pstn%' OR dcontext LIKE 'ivr-%')
                    ORDER BY calldate DESC LIMIT $limit";
                    
            $stmt = $pdo->query($sql);
            while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
                $d = new DateTime($row['calldate']);
                $row['time'] = $d->format('H:i');
                $row['date'] = $d->format('Y-m-d');
                $row['src'] = empty($row['src']) ? 'ناشناس' : $row['src'];
                
                $trunk_name = 'نامشخص';
                if (preg_match('/^(SIP|PJSIP|DAHDI)\/([^\-]+)/i', $row['channel'], $matches)) {
                    $trunk_name = $matches[2];
                }
                $row['trunk'] = $trunk_name;
                
                $missed[] = $row;
            }
        } catch (PDOException $e) { }
        return $missed;
    }
}
