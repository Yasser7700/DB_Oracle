# دليل التثبيت الشامل
## نظام التجارة الإلكترونية الآمن - Oracle 19c

---

## المتطلبات الأساسية

- Oracle Database 19c Enterprise Edition
- صلاحيات SYSDBA
- 50GB مساحة حرة
- 8GB RAM كحد أدنى

---

## خطوات التثبيت

### المرحلة 1: إعداد البيئة (15-30 دقيقة)

1. **الاتصال كـ SYSDBA**
   ```
   sqlplus / as sysdba
   ```

2. **إنشاء PDB**
   ```sql
   @02_Database_Scripts/01_Setup/01_Create_PDB.sql
   ```

3. **إنشاء Tablespaces**
   ```sql
   ALTER SESSION SET CONTAINER = ECOM_PDB;
   @02_Database_Scripts/01_Setup/02_Create_Tablespaces.sql
   ```

4. **إنشاء المستخدمين**
   ```sql
   @02_Database_Scripts/01_Setup/03_Create_Schemas.sql
   ```

---

### المرحلة 2: كائنات المخطط (20-40 دقيقة)

1. **الاتصال كـ ECOM_OWNER**
   ```
   sqlplus ECOM_OWNER/EcomOwner#2024@localhost:1521/ECOM_PDB
   ```

2. **إنشاء الجداول**
   ```sql
   @02_Database_Scripts/02_Schema_Objects/01_Create_Tables.sql
   ```

3. **إنشاء الفهارس**
   ```sql
   @02_Database_Scripts/02_Schema_Objects/02_Create_Indexes.sql
   ```

4. **تحميل البيانات**
   ```sql
   @02_Database_Scripts/02_Schema_Objects/03_Load_Sample_Data.sql
   ```

5. **قاموس البيانات**
   ```sql
   @02_Database_Scripts/02_Schema_Objects/04_Data_Dictionary.sql
   ```

---

### المرحلة 3: تنفيذ الأمان (30-45 دقيقة)

1. **الاتصال كـ SYSDBA**

2. **الأدوار والصلاحيات**
   ```sql
   @02_Database_Scripts/03_Security_Implementation/01_RBAC_Roles.sql
   ```

3. **سياسات كلمات المرور**
   ```sql
   @02_Database_Scripts/03_Security_Implementation/02_Password_Profiles.sql
   ```

4. **سياسات VPD** (كـ SEC_ADMIN)
   ```sql
   @02_Database_Scripts/03_Security_Implementation/03_VPD_Policies.sql
   ```

5. **العروض المقيدة**
   ```sql
   @02_Database_Scripts/03_Security_Implementation/04_Access_Views.sql
   ```

6. **صلاحيات الأعمدة**
   ```sql
   @02_Database_Scripts/03_Security_Implementation/05_Column_Privileges.sql
   ```

---

### المرحلة 4: حماية الخصوصية (20-30 دقيقة)

1. **الإخفاء الثابت**
   ```sql
   @02_Database_Scripts/04_Privacy_Protection/01_Static_Masking.sql
   ```

2. **الإخفاء الديناميكي** (كـ SYSDBA)
   ```sql
   @02_Database_Scripts/04_Privacy_Protection/02_Dynamic_Masking.sql
   ```

3. **التوكنة**
   ```sql
   @02_Database_Scripts/04_Privacy_Protection/03_Tokenization.sql
   ```

4. **إزالة التعريف**
   ```sql
   @02_Database_Scripts/04_Privacy_Protection/04_Pseudonymization.sql
   ```

---

### المرحلة 5: التدقيق والمراقبة (20-30 دقيقة)

1. **سياسات التدقيق** (كـ SYSDBA)
   ```sql
   @02_Database_Scripts/05_Audit_Monitoring/01_Audit_Policies.sql
   ```

2. **التدقيق الدقيق FGA**
   ```sql
   @02_Database_Scripts/05_Audit_Monitoring/02_FGA_Policies.sql
   ```

3. **استعلامات المراقبة**
   ```sql
   @02_Database_Scripts/05_Audit_Monitoring/03_Monitoring_Queries.sql
   ```

4. **إجراءات التنبيه**
   ```sql
   @02_Database_Scripts/05_Audit_Monitoring/04_Alert_Procedures.sql
   ```

---

### المرحلة 6: الصيانة

1. **فحوصات التأمين**
   ```sql
   @02_Database_Scripts/06_Maintenance/01_Hardening_Checks.sql
   ```

2. **تقارير الامتثال**
   ```sql
   @02_Database_Scripts/06_Maintenance/02_Compliance_Reports.sql
   ```

3. **إجراءات النسخ الاحتياطي**
   ```sql
   @02_Database_Scripts/06_Maintenance/03_Backup_Procedures.sql
   ```

---

## التحقق من التثبيت

راجع الملفات في مجلد `01_VALIDATION_QUERIES` للتحقق من نجاح التثبيت.

---

## معلومات الاتصال

| المستخدم | كلمة المرور | الدور |
|----------|-------------|-------|
| ECOM_OWNER | EcomOwner#2024 | مالك المخطط |
| SEC_ADMIN | SecAdmin#2024 | مسؤول الأمان |
| CS_AGENT | CsAgent#2024 | خدمة العملاء |
| WAREHOUSE_STAFF | Warehouse#2024 | المستودع |
| AUDITOR | Auditor#2024 | المدقق |

> ⚠️ **تحذير**: غيّر كلمات المرور فوراً في بيئة الإنتاج!
