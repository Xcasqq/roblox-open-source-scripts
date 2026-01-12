-- ESP Kapatma Scripti
if getgenv().ESP_ON ~= nil then
    getgenv().ESP_ON = false
    print("3D Box ESP kapatıldı!")
else
    print("ESP scripti bulunamadı veya henüz yüklenmedi!")
end
