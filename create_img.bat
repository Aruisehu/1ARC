dd if=bin\bootstrap.bin of=img\final_en.img
dd if=bin\bootstrap.bin of=img\final_fr.img
dd if=bin\main_en.bin of=img\final_en.img oflag=seek_bytes seek=512
dd if=bin\main_fr.bin of=img\final_fr.img oflag=seek_bytes seek=512