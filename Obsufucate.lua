
-- EMLOXA WARE CORE DECRYPTOR
-- Bu dosya sunucuda kalır, oyuncular göremez.

return function(encryptedData, baseKey, ...)
    local decryptedString = ""
    
    -- Rolling XOR Çözümlemesi
    for i = 1, #encryptedData do
        -- Javascript tarafındaki aynı matematik: (baseKey + index - 1) % 256
        local rollingKey = (baseKey + (i - 1)) % 256
        
        -- bit32 kütüphanesi ile şifreyi çöz ve karaktere çevir
        local charCode = bit32.bxor(encryptedData[i], rollingKey)
        decryptedString = decryptedString .. string.char(charCode)
    end
    
    -- Çözülen kodu bellekte derle
    local executeFunc, errorMessage = loadstring(decryptedString)
    
    if not executeFunc then
        error("[EMLOXA WARE FATAL] Integrity verification failed: " .. tostring(errorMessage))
    end
    
    -- Orijinal scripti çalıştır
    return executeFunc(...)
end
