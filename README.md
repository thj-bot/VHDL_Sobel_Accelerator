#SOBEL EDGE DETECTİON FPGA ACCELERATOR
Bu proje, görüntü üzerindeki kenarları tespit eden bir algoritmanın (Sobel) FPGA üzerinde çok düşük kaynak harcayarak çalışması için tasarlanmıştır.

TEMEL ÖZELLİKLER

Çarpma blokları (DSP) yerine kaydırma işlemleri kullanılarak sistem optimize edildi.

Toplamda sadece 152 LUT kullanılarak çok az alan kaplayan bir tasarım yapıldı.

Python ile hazırlanan referans model (Golden Model) ile donanım çıktısı tam uyumludur.

KLASÖRLERİN İÇERİĞİ

src: Ana donanım kodları (VHDL)
sim: Test ve simülasyon dosyası
model: Python referans kodları ve giriş resmi
output: Donanımdan çıkan sonuç verileri ve final resmi
docs: Donanım raporları ve görseller

NASIL ÇALIŞTIRILIR

İlk olarak model klasöründeki Python koduyla giriş verileri hazırlanır.

Vivado üzerinde simülasyon çalıştırılarak donanım sonuçları üretilir.

output klasöründeki Python koduyla bu sonuçlar tekrar resme dönüştürülür.
