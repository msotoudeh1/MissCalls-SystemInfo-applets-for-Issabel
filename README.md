اپلت تماسهای از دست رفته به تفکیک ترانک ها و داخلی ها . با قابلیت صفحه بندی و مشاهده گزارش بر اساس روزانه و هفته و ماه

<img width="935" height="346" alt="image" src="https://github.com/user-attachments/assets/ce976b81-3878-42bd-8f91-961f715f3109" />


درود . 

 1- به مسیر زیر در ایزابل رفته دو پوشه IssabelMissedCalls و  IssabelAlarms  به طور کامل به پوشه applets منتقل کنید .

```
 /var/www/html/modules/dashboard/applets
```
 

2- فایل های index.php موجود در پوشه های IssabelAlarms و IssabelMissedCalls را باز کرده و به جای database_password رمز دیتابیس ایزابل خود را قرار دهید 
 
 3- تمام محتویات موجود در پوشه file رابه پوشه html در ایزابل منتقل کنید :
```
/var/www/html
```
 4- سپس در محیط کنسول ایزابل دستورات زیر  را به ترتیب وارد کنید :

```
chown -R asterisk:asterisk /var/www/html/modules/dashboard/applets/IssabelMissedCalls/

```

```
chown -R asterisk:asterisk /var/www/html/modules/dashboard/applets/IssabelAlarms/

```

 5. ثبت اپلت تماس‌های از دست رفته

```
sqlite3 /var/www/db/dashboard.db "INSERT INTO applet (code, name, icon) VALUES ('Applet_IssabelMissedCalls', 'تماس‌های از دست رفته', 'missed.png');"

```

```
sqlite3 /var/www/db/dashboard.db "INSERT INTO default_applet_by_user (id_applet, username) SELECT id, 'admin' FROM applet WHERE code='Applet_IssabelMissedCalls';"

```

 6. ثبت اپلت هشدارهای سیستم


```
sqlite3 /var/www/db/dashboard.db "INSERT INTO applet (code, name, icon) VALUES ('Applet_IssabelAlarms', 'هشدارهای سیستم', 'alarm.png');"

```

```
sqlite3 /var/www/db/dashboard.db "INSERT INTO default_applet_by_user (id_applet, username) SELECT id, 'admin' FROM applet WHERE code='Applet_IssabelAlarms';"

```

 7. پاک کردن کش ایزابل


```
rm -rf /var/www/html/var/templates_c/*

```

در نهایت از بخش مدیریت میز کار و یا applets_admin دو اپلت را فعال نمائید 
