# ETL Documentation (Dokumentasi Teknis)

**Target Audiens:** Developer / Data Engineer selanjutnya.  
**Tujuan:** Menjelaskan mekanisme perpindahan data dari mentah (raw) menjadi matang (warehouse), termasuk pemetaan dan logika transformasi.

---

## A. Arsitektur Data

* **Metode:** ELT (*Extract, Load, Transform*).
* **Alur Data:** `Source System (OLTP)` &rarr; `Staging Area (stg.*)` &rarr; `Data Warehouse (dbo.*)`.
* **Tools & Teknologi:** * SSMS (SQL Server Management Studio)
    * T-SQL Stored Procedures
    * SSIS (SQL Server Integration Services) - *[Jika digunakan]*

---

## B. Source-to-Target Mapping (STTM)

Berikut adalah pemetaan tabel sumber ke tabel tujuan beserta strategi pemuatannya:

| Tabel Source | Tabel Target | Tipe Load | Logika Bisnis |
| :--- | :--- | :--- | :--- |
| `tb_dosen` | `Dim_Dosen` | **SCD Type 2** | Jika `Jabatan_Fungsional` berubah, row lama akan expire (`EndDate` diisi hari ini), dan row baru di-insert dengan status aktif (`IsCurrent=1`). |
| `tb_mahasiswa` | `Dim_Mahasiswa` | **SCD Type 1** | Update langsung (overwrite) untuk perubahan atribut biasa (seperti No HP, Alamat). Tidak menyimpan histori. |
| `tb_krs` / `tb_nilai` | `Fact_Akademik` | **Incremental** | Data transaksi pengambilan SKS dan Nilai dimuat secara bertahap berdasarkan data baru yang masuk. |

---

## C. Penanganan Perubahan Data (SCD Strategy)

Sistem menerapkan strategi **SCD (Slowly Changing Dimension) Type 2** secara spesifik pada **Dimensi Dosen** untuk menangani perubahan jabatan.

* **Trigger (Pemicu):** Terdeteksi perubahan data pada kolom `Jabatan_Fungsional` di tabel sumber.
* **Mekanisme Teknis:**
    1.  **Expire Record Lama:** Update kolom `EndDate` pada record lama menjadi `GETDATE()` dan set `IsCurrent = 0`.
    2.  **Insert Record Baru:** Masukkan baris data baru dengan jabatan terbaru, set `StartDate = GETDATE()`, `EndDate = NULL`, dan `IsCurrent = 1`.

---

## D. Error Handling (Penanganan Error)

Mekanisme pemantauan kualitas data saat proses ETL berjalan:

* **Pencatatan Log:** Jika terjadi kegagalan load atau data tidak memenuhi aturan validasi, error dicatat ke dalam tabel `dbo.DataQuality_Log`.
* **Status Indikator:** * `PASS`: Data berhasil dimuat dan valid.
    * `FAIL`: Data gagal dimuat atau melanggar constraint.
* **Tindak Lanjut:** Admin/Developer wajib memeriksa tabel log jika ditemukan status 'FAIL' untuk melakukan perbaikan data di hulu (Source System).
