# Design Documents - Data Mart Fakultas Sains

Dokumen ini mencakup perancangan Konseptual (ERD), Logikal (Dimensional Model), dan Kamus Data.

## 1. Conceptual Design (ERD)
Perancangan ini mengidentifikasi entitas utama dalam kegiatan akademik dan penelitian di Fakultas Sains.

### Entity Relationship Diagram
<img width="1371" height="591" alt="image" src="https://github.com/user-attachments/assets/fb19459d-2ede-4e9d-8336-6102aea19449" />


### Deskripsi Entitas Utama
* **Entitas Master**: `Program Studi` (sebagai acuan utama), `Mahasiswa`, `Dosen`, `Mata Kuliah`, dan `Jurnal` .
* **Entitas Transaksional**:
    * KRS_Nilai`: Mencatat aktivitas pengambilan mata kuliah dan penilaian per semester.
    * `Publikasi_Dosen`: Mencatat output penelitian dosen yang terhubung ke jurnal.
