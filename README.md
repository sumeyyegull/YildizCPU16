# YILDIZ 16-bit CPU (Verilog)
Bu projede, Verilog HDL ile donanım seviyesinde YILDIZ isimli 16-bit özel bir işlemci tasarlanmıştır. Tasarım; ALU, kontrol birimi, register bankası, RAM ve veri yolu gibi temel modüllerden oluşur. Tüm modüller birleştirilerek bütünsel bir CPU mimarisi elde edilmiştir.
Ana Modüller:
alu.v: Aritmetik ve mantıksal işlemler
ram_16bit.v: 16-bit RAM
control_unit.v: Kontrol birimi (FSM)
register_bank.v: Register dosyası (R0–R7, SP, ISR)
data_path.v: Veri yolu ve bağlantılar
yildiz_cpu_16bit.v: Ana CPU modülü
YildizCPU16_tb.v: Testbench (doğrulama için)
Kullanım:
Test için YildizCPU16_tb.v dosyasını bir Verilog simülatöründe çalıştırabilirsiniz.
